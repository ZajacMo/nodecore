-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, setmetatable, vector
    = ItemStack, math, minetest, nodecore, setmetatable, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function settle(self)
	local rawpos = self.object:get_pos()
	local pos = vector.round(rawpos)
	local i = ItemStack(self.itemstring)
	pos = nodecore.scan_flood(pos, 5,
		function(p)
			if p.y > pos.y and math_random() < 0.95 then return end
			if p.y > pos.y + 1 then return end
			i = nodecore.stack_add(p, i)
			if i:is_empty() then return p end
			if nodecore.buildable_to(p) then return p end
		end)
	if not pos then return end
	if not i:is_empty() then
		nodecore.place_stack(pos, i, nil, nil, rawpos)
	end
	self.itemstring = ""
	self.object:remove()
	return true
end

local bii = minetest.registered_entities["__builtin:item"]
local newbii = {
	on_step = function(self, dtime, ...)
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
