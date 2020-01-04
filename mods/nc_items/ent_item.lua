-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, setmetatable, vector
    = ItemStack, math, minetest, nodecore, setmetatable, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function settle(self)
	local pos = vector.round(self.object:get_pos())
	local node = minetest.get_node(pos)
	if node.name == "ignore" then return end
	node = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	if node.name == "ignore" then return end
	local item = ItemStack(self.itemstring)
	for rel in nodecore.settlescan() do
		local p = vector.add(pos, rel)
		item = nodecore.stack_add(p, item)
		if item:is_empty() then
			self.itemstring = ""
			self.object:remove()
			return true
		end
		if nodecore.buildable_to(p) and (rel.y <= 0
			or nodecore.walkable({x = p.x, y = p.y - 1, z = p.z})) then
			nodecore.place_stack(p, item)
			self.itemstring = ""
			self.object:remove()
			return true
		end
	end
	self.itemstring = item:to_string()
end

local bii = minetest.registered_entities["__builtin:item"]
local newbii = {
	on_step = function(self, dtime, ...)
		self.object:set_acceleration(nodecore.grav_air_accel(self.object:get_velocity()))
		bii.on_step(self, dtime, ...)
		if not self.moving_state then
			return settle(self)
		end
	end,
	disable_physics = function(self, ...)
		if settle(self) then return end
		return bii.disable_physics(self, ...)
	end,
	on_punch = function(self, whom, ...)
		if not nodecore.interact(whom) then return end
		bii.on_punch(self, whom, ...)
		if self.itemstring ~= "" then
			local v = self.object:get_velocity()
			v.x = v.x + math_random() * 5 - 2.5
			v.y = v.y + math_random() * 5 - 2.5
			v.z = v.z + math_random() * 5 - 2.5
			self.object:set_velocity(v)
		end
	end
}
setmetatable(newbii, bii)
minetest.register_entity(":__builtin:item", newbii)
