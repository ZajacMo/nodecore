-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, setmetatable, vector
    = ItemStack, math, minetest, nodecore, setmetatable, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local bii = minetest.registered_entities["__builtin:item"]
local newbii = {
	on_step = function(self, dtime, ...)
		bii.on_step(self, dtime, ...)

		local pos = self.object:get_pos()
		if not self.oldpos or not vector.equals(pos, self.oldpos) then
			self.oldpos = pos
			self.sitting = 0
			return
		end
		self.sitting = (self.sitting or 0) + dtime
		if self.sitting < 0.25 then return end

		pos = vector.round(pos)
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
		if not i:is_empty() then nodecore.place_stack(pos, i) end
		self.itemstring = ""
		self.object:remove()
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
