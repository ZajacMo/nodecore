-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, ipairs, nc, pairs, table, vector
    = ItemStack, core, ipairs, nc, pairs, table, vector
local table_shuffle
    = table.shuffle
-- LUALOCALS > ---------------------------------------------------------

nc.register_falling_node_step,
nc.registered_falling_node_steps
= nc.mkreg()

nc.register_falling_node_on_setnode,
nc.registered_falling_node_on_setnodes
= nc.mkreg()

local data_load, data_save = nc.entity_staticdata_helpers({
		maxy = true,
		node = true,
		meta = true,
		vel = true,
		setvel = true
	})

local hand = ItemStack("")
local function displace_check(pos)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if def and def.buildable_to then return end
	if def and def.diggable and def.drop ~= nil and def.drop ~= node.name
	and nc.tool_digs(hand, def.groups) then
		nc.protection_bypass(core.dig_node, pos)
	end
	for rel in nc.settlescan() do
		local p = vector.add(pos, rel)
		if nc.buildable_to(p) then
			nc.set_loud(p, node)
			core.get_meta(p):from_table(
				core.get_meta(pos):to_table()
			)
			nc.remove_node(pos)
			return nc.fallcheck(p)
		end
	end
	local drops = core.get_node_drops(pos, "")
	for _, item in pairs(drops) do
		core.add_item(pos, item)
	end
end

local function fallopencheck(pos)
	return nc.buildable_to(pos)
	and nc.buildable_to(vector.offset(pos, 0, -1, 0))
end
local fallopendirs = {
	vector.new(1, 0, 0),
	vector.new(-1, 0, 0),
	vector.new(0, 0, 1),
	vector.new(0, 0, -1)
}

core.register_entity(":__builtin:falling_node", {
		initial_properties = {
			visual = "wielditem",
			visual_size = {x = 2/3, y = 2/3},
			textures = {},
			pointable = false,
			physical = true,
			is_visible = false,
			collide_with_objects = false,
			collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},

		get_staticdata = data_save,

		on_activate = function(self, data)
			self.object:set_armor_groups({immortal = 1})
			nc.entity_update_maxy(self)
			data_load(self, data)
		end,

		set_node = function(self, node, meta)
			if not node then return self.object:remove() end

			self.node = node
			self.represents_item = self.node and self.node.name
			local def = core.registered_items[node.name]
			if def.falling_replacement then
				self.node.name = def.falling_replacement
			end
			self.object:set_properties({
					is_visible = true,
					textures = {def and def.falling_visual or node.name},
				})

			self.meta = nc.meta_serializable(meta)

			for _, func in ipairs(nc.registered_falling_node_on_setnodes) do
				if func(self, node, meta) == true then return end
			end
		end,

		settle_check = nc.entity_settle_check(function(self, pos, collides)
				if collides(pos) then
					pos.y = pos.y + 1
					self.object:set_pos(pos)
					return
				end

				local below = {x = pos.x, y = pos.y - 1, z = pos.z}
				local node = core.get_node(below)
				local def = core.registered_nodes[node.name] or {}
				local selfdef = core.registered_nodes[self.node.name] or {}
				if def.groups and def.groups.is_stack_only then
					if selfdef.walkable ~= false then
						nc.protection_bypass(core.dig_node, below)
						return
					else
						table_shuffle(fallopendirs)
						for _, dir in ipairs(fallopendirs) do
							local p = vector.add(pos, dir)
							if fallopencheck(p) then
								self.object:set_pos(p)
								return
							end
						end
					end
				end

				displace_check(pos)

				nc.set_loud(pos, self.node)
				if self.meta then
					core.get_meta(pos):from_table(self.meta)
				end
				self.object:remove()

				if def.on_falling_node_crush then
					def.on_falling_node_crush(below, node)
				end

				return true
			end,
			true),

		on_step = function(self, ...)
			if not self.node then return self.object:remove() end
			nc.entity_update_maxy(self)
			if self:settle_check(...) then return end

			for _, func in ipairs(nc.registered_falling_node_steps) do
				if func(self, ...) == true then return end
			end
		end
	})

nc.register_falling_node_step(function(self, dtime)
		if not (self.node and self.node.name) then return end

		local pos = self.object:get_pos()
		if not pos then return end

		self.aismtime = (self.aismtime or 0) + dtime
		if self.aismtime < 1 then return end
		self.aismtime = self.aismtime - 1

		local istack = ItemStack(self.node.name)
		istack:get_meta():from_table(self.meta)

		local sdata = {
			pos = pos,
			fallingent = self,
			set = function(s)
				local name = s:get_name()
				if core.registered_nodes[name] then
					self.node.name = name
					self.meta = s:get_meta():to_table()
				else
					local ent = core.add_item(pos, s)
					if ent then ent:set_velocity(self.object:get_velocity()) end
					return self.object:remove()
				end
			end
		}
		nc.aism_check_stack(istack, sdata)
	end)
