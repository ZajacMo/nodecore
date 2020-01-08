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

local data_load, data_save = nodecore.entity_staticdata_helpers({
		node = true,
		meta = true,
		vel = true,
		setvel = true
	})

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

local function findalt(pos, collides)
	for p in nodecore.settlescan(pos) do
		p = vector.add(pos, p)
		if not collides(p) then return p end
	end
	return pos
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

		get_staticdata = data_save,

		on_activate = function(self, data)
			self.object:set_armor_groups({immortal = 1})
			return data_load(self, data)
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

		settle_check = nodecore.entity_settle_check(function(self, pos, collides)
				if collides(pos) then pos = findalt(pos, collides) end

				displace_check(pos)

				minetest.set_node(pos, self.node)
				nodecore.node_sound(pos, "place")
				if self.meta then
					minetest.get_meta(pos):from_table(self.meta)
				end
				self.object:remove()
			end),

		on_step = function(self, ...)
			if not self.node then return self.object:remove() end
			if self:settle_check() then return end

			for _, func in ipairs(nodecore.registered_falling_node_steps) do
				if func(self, ...) == true then return end
			end
		end
	})
