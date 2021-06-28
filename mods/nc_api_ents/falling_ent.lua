-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
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
			nodecore.set_loud(p, node)
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
			pointable = false,
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
			local def = minetest.registered_items[node.name]
			self.object:set_properties({
					is_visible = true,
					textures = {def and def.falling_visual or node.name},
				})

			self.meta = nodecore.meta_serializable(meta)

			for _, func in ipairs(nodecore.registered_falling_node_on_setnodes) do
				if func(self, node, meta) == true then return end
			end
		end,

		settle_check = nodecore.entity_settle_check(function(self, pos, collides)
				if collides(pos) then
					pos.y = pos.y + 1
					self.object:set_pos(pos)
					return
				end

				local below = {x = pos.x, y = pos.y - 1, z = pos.z}
				local node = minetest.get_node(below)
				local def = minetest.registered_nodes[node.name] or {}
				if def.groups and def.groups.is_stack_only then
					minetest.dig_node(below)
					return
				end

				displace_check(pos)

				nodecore.set_loud(pos, self.node)
				if self.meta then
					minetest.get_meta(pos):from_table(self.meta)
				end
				self.object:remove()

				return true
			end,
			true),

		on_step = function(self, ...)
			if not self.node then return self.object:remove() end
			if self:settle_check() then return end

			for _, func in ipairs(nodecore.registered_falling_node_steps) do
				if func(self, ...) == true then return end
			end
		end
	})
