-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, setmetatable, vector
    = minetest, nodecore, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local down = {x = 0, y = -1, z = 0}

local bifn = minetest.registered_entities["__builtin:falling_node"]
local falling = {
	on_step = function(self, ...)
		local pos = vector.round(self.object:get_pos())
		self.dooroppos = self.dooroppos or pos
		if not vector.equals(pos, self.dooroppos) then
			self.dooroppos = pos
			minetest.after(0, function()
					nodecore.operate_door({
							x = pos.x + 1,
							y = pos.y,
							z = pos.z
						}, nil, down)
					nodecore.operate_door({
							x = pos.x - 1,
							y = pos.y,
							z = pos.z
						}, nil, down)
					nodecore.operate_door({
							x = pos.x,
							y = pos.y,
							z = pos.z + 1
						}, nil, down)
					nodecore.operate_door({
							x = pos.x,
							y = pos.y,
							z = pos.z - 1
						}, nil, down)
				end)
		end
		return bifn.on_step(self, ...)
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)
