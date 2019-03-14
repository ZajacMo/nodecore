-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, setmetatable
    = minetest, nodecore, setmetatable
-- LUALOCALS > ---------------------------------------------------------

local function place(self, pos)
	minetest.set_node(pos, self.node)
	if self.meta then minetest.get_meta(pos):from_table(self.meta) end
	self.object:remove()
	return minetest.check_for_falling(pos)
end

local bifn = minetest.registered_entities["__builtin:falling_node"]
local old_step = bifn.on_step
local falling = {
	on_step = function(self, ...)
		local pos = self.object:get_pos()
		local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
		if not nodecore.buildable_to(bcp) then
			if nodecore.buildable_to(pos) then return place(self, pos) end
			pos.y = pos.y + 0.3
			if nodecore.buildable_to(pos) then return place(self, pos) end
		end
		return old_step(self, ...)
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)
