-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, vector
    = ItemStack, ipairs, math, minetest, nodecore, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local stackonly = nodecore.group_expand("group:is_stack_only", true)

local function nuke(self)
	self.itemstring = ""
	self.object:remove()
	return true
end

local hand = ItemStack("")
nodecore.register_item_entity_on_settle(function(self, pos)
		local curnode = minetest.get_node(pos)
		if curnode.name == "ignore" then return end

		local below = {x = pos.x, y = pos.y - 0.55, z = pos.z}
		local bnode = minetest.get_node(below)

		if (pos.y - 1 >= nodecore.map_limit_min) and (bnode.name == "ignore")
		then return end

		local item = ItemStack(self.itemstring)
		item = nodecore.stack_settle(pos, item, curnode, nil, true)
		if item:is_empty() then return nuke(self) end
		if nodecore.stack_can_fall_in(below, item, bnode, nil, self) then
			self.object:set_pos({x = pos.x, y = pos.y - 0.55, z = pos.z})
			self.object:set_velocity({x = 0, y = 0, z = 0})
			return
		end
		item = nodecore.stack_settle(below, item, bnode)
		if item:is_empty() then return nuke(self) end

		if self.nextscan and nodecore.gametime < self.nextscan then return end
		self.nextscan = (self.nextscan or nodecore.gametime) + 0.75 + 0.5 * math_random()

		local boxes = {}
		for rel in nodecore.settlescan() do
			local p = vector.add(pos, rel)
			local n = minetest.get_node(p)
			if stackonly[n.name] then
				item = nodecore.stack_add(p, item)
				if item:is_empty() then return nuke(self) end
			else
				boxes[#boxes + 1] = p
			end
			if ((p.y >= nodecore.map_limit_min)
				and (rel.y <= 0 or (p.y - 1 < nodecore.map_limit_min)
					or nodecore.walkable({x = p.x, y = p.y - 1, z = p.z}))) then
				if not nodecore.buildable_to(p) then
					local node = minetest.get_node(p)
					local def = minetest.registered_nodes[node.name]
					if def and (not def.walkable) and def.diggable
					and nodecore.tool_digs(hand, def.groups) then
						minetest.dig_node(p)
					end
				end
				if nodecore.buildable_to(p) then
					nodecore.place_stack(p, item)
					minetest.get_meta(p):set_string("tweenfrom",
						minetest.serialize(self.object:get_pos()))
					return nuke(self)
				end
			end
		end
		for _, p in ipairs(boxes) do
			item = nodecore.stack_add(p, item)
			if item:is_empty() then return nuke(self) end
		end
		self.itemstring = item:to_string()
	end)
