-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, ipairs, math, nc, pairs, vector
    = ItemStack, core, ipairs, math, nc, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local stackonly = nc.group_expand("group:is_stack_only", true)

local function nuke(self)
	self.itemstring = ""
	self.object:remove()
	return true
end

local can_settle_on = {}
core.after(0, function()
		for k, v in pairs(core.registered_nodes) do
			if v.walkable or (v.groups and v.groups.support_falling or 0) > 0 then
				can_settle_on[k] = true
			end
		end
	end)

local hand = ItemStack("")
nc.register_item_entity_on_settle(function(self, pos)
		local curnode = core.get_node(pos)
		if curnode.name == "ignore" then return end

		local below = {x = pos.x, y = pos.y - 0.55, z = pos.z}
		local bnode = core.get_node(below)

		if (pos.y - 1 >= nc.map_limit_min) and (bnode.name == "ignore")
		then return end

		local item = ItemStack(self.itemstring)
		item = nc.stack_settle(pos, item, curnode, nil, true)
		if item:is_empty() then return nuke(self) end
		if nc.stack_can_fall_in(below, item, bnode, nil, self) then
			self.object:set_pos({x = pos.x, y = pos.y - 0.55, z = pos.z})
			self.object:set_velocity({x = 0, y = 0, z = 0})
			return
		end
		item = nc.stack_settle(below, item, bnode)
		if item:is_empty() then return nuke(self) end

		if self.nextscan and nc.gametime < self.nextscan then return end
		self.nextscan = (self.nextscan or nc.gametime) + 0.75 + 0.5 * math_random()

		local function placeat(p)
			nc.place_stack(p, item)
			nc.visinv_tween_from(p, self.object:get_pos())
			return nuke(self)
		end

		local itemname = item:get_name()
		local function trydig(p)
			local node = core.get_node(p)
			if node.name ~= itemname then
				local def = core.registered_nodes[node.name]
				if def and (not def.walkable) and def.diggable
				and nc.tool_digs(hand, def.groups) then
					nc.protection_bypass(core.dig_node, p)
					return placeat(p)
				end
			end
		end

		local boxes = {}
		local digs = {}
		for rel in nc.settlescan() do
			local p = vector.add(pos, rel)
			local n = core.get_node(p)
			if stackonly[n.name] then
				item = nc.stack_add(p, item)
				if item:is_empty() then return nuke(self) end
			else
				boxes[#boxes + 1] = p
			end
			if ((p.y >= nc.map_limit_min)
				and (rel.y <= 0 or (p.y - 1 < nc.map_limit_min)
					or can_settle_on[core.get_node(
						{x = p.x, y = p.y - 1, z = p.z})
					.name])) then
				if nc.buildable_to(p) then
					return placeat(p)
				elseif rel.x == 0 and rel.z == 0 and math_random(1, 10) == 1 then
					if trydig(p) then return true end
				else
					digs[#digs + 1] = p
				end
			end
		end
		for _, p in ipairs(boxes) do
			item = nc.stack_add(p, item)
			if item:is_empty() then return nuke(self) end
		end
		for _, p in ipairs(digs) do
			if trydig(p) then return true end
		end
		self.itemstring = item:to_string()
	end)
