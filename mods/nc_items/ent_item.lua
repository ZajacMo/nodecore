-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local stackonly = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.groups and v.groups.is_stack_only then
				stackonly[k] = true
			end
		end
	end)

nodecore.register_item_entity_on_settle(function(self, pos)
		local node = minetest.get_node(pos)
		if node.name == "ignore" then return end
		if pos.y - 1 >= nodecore.map_limit_min then
			node = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
			if node.name == "ignore" then return end
		end

		if self.nextscan and nodecore.gametime < self.nextscan then return end
		self.nextscan = (self.nextscan or nodecore.gametime) + 0.75 + 0.5 * math_random()

		local boxes = {}
		local item = ItemStack(self.itemstring)
		for rel in nodecore.settlescan() do
			local p = vector.add(pos, rel)
			local n = minetest.get_node(p)
			if stackonly[n.name] then
				item = nodecore.stack_add(p, item)
				if item:is_empty() then
					self.itemstring = ""
					self.object:remove()
					return true
				end
			else
				boxes[#boxes + 1] = p
			end
			if nodecore.buildable_to(p) and (p.y >= nodecore.map_limit_min)
			and (rel.y <= 0 or (p.y - 1 < nodecore.map_limit_min)
				or nodecore.walkable({x = p.x, y = p.y - 1, z = p.z})) then
				nodecore.place_stack(p, item)
				minetest.get_meta(p):set_string("tweenfrom",
					minetest.serialize(self.object:get_pos()))
				self.itemstring = ""
				self.object:remove()
				return true
			end
		end
		for _, p in pairs(boxes) do
			item = nodecore.stack_add(p, item)
			if item:is_empty() then
				self.itemstring = ""
				self.object:remove()
				return true
			end
		end
		self.itemstring = item:to_string()
	end)
