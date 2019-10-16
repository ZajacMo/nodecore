-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, setmetatable, vector
    = minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local function signal(pos, ...)
	pos = vector.round(pos)
	pos.y = pos.y + 1
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2)) do
		if vector.equals(vector.round(obj:get_pos()), pos) then
			obj = obj.get_luaentity and obj:get_luaentity()
			if obj and obj.on_force_settle then
				obj:on_force_settle(pos)
				return signal(pos, ...)
			end
		end
	end
	return ...
end

local bifn = minetest.registered_entities["__builtin:falling_node"]
local falling = {
	on_force_settle = function(self, pos)
		local def = minetest.registered_nodes[self.node.name]
		if def then
			minetest.add_node(pos, self.node)
			if self.meta then
				minetest.get_meta(pos):from_table(self.meta)
			end
			nodecore.node_sound(pos, "place")
		end
		self.object:remove()
		minetest.check_for_falling(pos)
	end,
	on_step = function(self, ...)
		local oldnode = minetest.add_node
		minetest.add_node = function(pos, node, ...)
			minetest.add_node = oldnode
			return signal(self.object:get_pos(),
				oldnode(pos, node, ...))
		end
		local function helper(...)
			minetest.add_node = oldnode
			return ...
		end
		return helper(bifn.on_step(self, ...))
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)
