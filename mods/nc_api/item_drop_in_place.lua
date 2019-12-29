-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, type
    = ItemStack, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes with a "drop_in_place" spec transform on node drop by dropping
into place of existing node instead of digger inventory.
--]]

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end
		local dip = def.drop_in_place
		if dip then
			if type(dip) ~= "table" then dip = {name = dip} end
			def.drop = def.drop or ""
			def.node_dig_prediction = def.node_dig_prediction or dip.name
			local st = def.silktouch
			if st == nil then
				st = {}
				for k, v in pairs(def.groups or {}) do
					st[k] = v + 5
				end
			end
			def.after_dig_node = def.after_dig_node or function(pos, node, _, digger)
				if st and digger and nodecore.tool_digs(
					digger:get_wielded_item(), st) then
					local stack = ItemStack(node.name)
					stack = digger:get_inventory():add_item("main",
						stack:to_string())
					if stack:is_empty() then return end
					do return nodecore.item_eject(pos, stack) end
				end
				dip.param2 = node.param2
				minetest.set_node(pos, dip)
			end
		end
	end)
