-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, type, vector
    = ipairs, minetest, nodecore, pairs, type, vector
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_falling_node_step,
nodecore.registered_falling_node_steps
= nodecore.mkreg()

nodecore.register_falling_node_on_setnode,
nodecore.registered_falling_node_on_setnodes
= nodecore.mkreg()

local area_unloaded = {}

local function collides(self, pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return area_unloaded end
	local def = minetest.registered_nodes[node.name]
	if not def then return node end
	if def.walkable then return node end
	if def.liquidtype ~= "none"
	and minetest.get_item_group(self.node.name, "float") ~= 0
	then return node end
end

local savedprops = {
	node = true,
	meta = true,
	vel = true,
	setvel = true
}

local function displace_check(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.buildable_to then return end
	for rel in nodecore.settlescan() do
		local p = vector.add(pos, rel)
		if nodecore.buildable_to(p) then
			minetest.set_node(p, node)
			minetest.get_meta(p):from_table(
				minetest.get_meta(pos):to_table()
			)
			nodecore.remove_node(pos)
			return nodecore.fallcheck(p)
		end
	end
	local drops = minetest.get_node_drops(pos, "")
	for _, item in pairs(drops) do
		minetest.add_item(pos, item)
	end
end

minetest.register_entity(":__builtin:falling_node", {
		initial_properties = {
			visual = "wielditem",
			visual_size = {x = 2/3, y = 2/3},
			textures = {},
			physical = true,
			is_visible = false,
			collide_with_objects = false,
			collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		},

		get_staticdata = function(self)
			local data = {}
			for k in pairs(savedprops) do data[k] = self[k] end
			return minetest.serialize(data)
		end,

		on_activate = function(self, data)
			self.object:set_armor_groups({immortal = 1})
			data = minetest.deserialize(data) or {}
			for k in pairs(savedprops) do self[k] = data[k] end
		end,

		set_node = function(self, node, meta)
			if not node then return self.object:remove() end

			self.node = node
			self.object:set_properties({
					is_visible = true,
					textures = {node.name},
				})

			meta = meta or {}
			if type(meta.to_table) == "function" then
				meta = meta:to_table()
			end
			for _, list in pairs(meta.inventory or {}) do
				for i, stack in pairs(list) do
					if type(stack) == "userdata" then
						list[i] = stack:to_string()
					end
				end
			end
			self.meta = meta

			for _, func in ipairs(nodecore.registered_falling_node_on_setnodes) do
				if func(self, node, meta) == true then return end
			end
		end,

		settle_check = function(self)
			local pos = self.object:get_pos()
			pos.y = pos.y - 0.75
			local coll = collides(self, pos)
			if not coll then
				if self.setvel then
					self.object:set_velocity(self.vel)
					self.setvel = nil
				end
				self.vel = self.object:get_velocity()
				return nodecore.grav_air_accel_ent(self.object)
			end
			if coll == area_unloaded then
				self.object:set_pos(vector.round(self.object.pos))
				self.object:set_velocity({x = 0, y = 0, z = 0})
				self.object:set_acceleration({x = 0, y = 0, z = 0})
				self.setvel = true
				return
			end
			pos = vector.round(pos)
			pos.y = pos.y + 1
			if collides(self, pos) then
				pos.y = pos.y + 1
				return self.object:set_pos(pos)
			end

			displace_check(pos)

			minetest.set_node(pos, self.node)
			nodecore.node_sound(pos, "place")
			if self.meta then
				minetest.get_meta(pos):from_table(self.meta)
			end
			self.object:remove()

			pos.y = pos.y + 1
			for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2)) do
				if vector.equals(vector.round(obj:get_pos()), pos) then
					obj = obj.get_luaentity and obj:get_luaentity()
					if obj and obj.settle_check then
						obj:settle_check()
					end
				end
			end

			return nodecore.fallcheck(pos)
		end,

		on_step = function(self, ...)
			if not self.node then return self.object:remove() end
			if self:settle_check() then return end

			for _, func in ipairs(nodecore.registered_falling_node_steps) do
				if func(self, ...) == true then return end
			end
		end
	})
