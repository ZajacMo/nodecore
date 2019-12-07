-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, table,
      vector
    = ItemStack, math, minetest, nodecore, pairs, setmetatable, table,
      vector
local math_random, table_sort
    = math.random, table.sort
-- LUALOCALS > ---------------------------------------------------------

local settleused
local settleorder = {}
do
	local groups = {}
	local keys = {}
	for x = -5, 5 do
		for y = -5, 5 do
			for z = -5, 5 do
				local p = {
					x = x,
					y = y,
					z = z,
				}
				local d = vector.length(p)
				if d <= 5 then
					p.v = d + p.y / 100
					local g = groups[p.v]
					if not g then
						g = {}
						groups[p.v] = g
						keys[#keys + 1] = p.v
					end
					g[#g + 1] = p
				end
			end
		end
	end
	table_sort(keys)
	for _, k in pairs(keys) do
		settleorder[#settleorder + 1] = groups[k]
	end
end

minetest.register_globalstep(function()
		if not settleused then return end
		settleused = nil
		for _, t in pairs(settleorder) do
			local n = #t
			for i = 1, n do
				local j = math_random(1, n)
				local x = t[i]
				t[i] = t[j]
				t[j] = x
			end
		end
	end)

local function settle(self)
	local pos = vector.round(self.object:get_pos())
	local item = ItemStack(self.itemstring)
	settleused = true
	for i = 1, #settleorder do
		local grp = settleorder[i]
		for j = 1, #grp do
			local p = vector.add(pos, grp[j])
			item = nodecore.stack_add(p, item)
			if item:is_empty() then
				self.itemstring = ""
				self.object:remove()
				return true
			end
			if nodecore.buildable_to(p) then
				nodecore.place_stack(p, item)
				self.itemstring = ""
				self.object:remove()
				return true
			end
		end
	end
	self.itemstring = item:to_string()
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
