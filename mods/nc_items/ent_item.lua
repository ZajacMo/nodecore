-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, vector
    = ItemStack, minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_item_entity_on_settle(function(self, pos)
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
	end)
