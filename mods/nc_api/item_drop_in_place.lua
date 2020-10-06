-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, type, vector
    = ItemStack, minetest, nodecore, pairs, type, vector
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes with a "drop_in_place" spec transform on node drop by dropping
into place of existing node instead of digger inventory.
--]]

local function yielditem(pos, digger, stack)
	if digger and digger:is_player() then
		stack = digger:get_inventory():add_item("main", stack)
	end
	if stack:is_empty() then return end
	return nodecore.item_eject(pos, stack)
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end
		local dip = def.drop_in_place
		if dip then
			if type(dip) ~= "table" then dip = {name = dip} end
			def.drop_non_silktouch = def.drop_non_silktouch
			or def.drop ~= "" and def.drop
			def.drop = ""
			def.node_dig_prediction = def.node_dig_prediction or dip.name
			local st = def.silktouch
			if st == nil then
				st = {}
				for k, v in pairs(def.groups or {}) do
					st[k] = v + 5
				end
			end
			def.after_dig_node = def.after_dig_node or function(pos, node, _, digger)
				local tool = digger and digger:is_player()
				and digger:get_wielded_item()
				or nodecore.machine_digging
				and vector.equals(nodecore.machine_digging.pos, pos)
				and nodecore.machine_digging.tool

				nodecore.machine_digging = nil

				if st and digger and nodecore.tool_digs(tool, st) then
					return yielditem(pos, digger, ItemStack(node.name))
				end

				dip.param2 = node.param2
				minetest.set_node(pos, dip)

				if def.drop_non_silktouch then
					return yielditem(pos, digger,
						ItemStack(def.drop_non_silktouch))
				end
			end
		end
	end)
