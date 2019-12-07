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
		local oldnode = minetest.get_node(pos)
		if oldnode.name == "ignore" then
			return self.object:remove()
		end
		if oldnode.name ~= "air" then
			local olddef = minetest.registered_nodes[oldnode.name]
			if olddef and (not olddef.buildable_to)
			and (olddef.liquidtype ~= "none") then
				for _, item in pairs(minetest.get_node_drops(oldnode, "")) do
					minetest.add_item(pos, item)
				end
			end
		end
		local def = minetest.registered_nodes[self.node.name]
		minetest.set_node(pos, def and self.node or {name = "air"})
		if self.meta then minetest.get_meta(pos):from_table(self.meta) end
		nodecore.node_sound(pos, "place")
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
