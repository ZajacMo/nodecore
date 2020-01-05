-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, vector
    = ItemStack, math, minetest, nodecore, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_item_entity_on_settle(function(self, pos)
		local node = minetest.get_node(pos)
		if node.name == "ignore" then return end
		node = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
		if node.name == "ignore" then return end
		if self.nextscan and nodecore.gametime < self.nextscan then return end
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
		self.nextscan = (self.nextscan or nodecore.gametime) + 0.75 + 0.5 * math_random()
	end)
