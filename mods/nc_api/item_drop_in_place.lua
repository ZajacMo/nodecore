-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes with a "drop_in_place" spec transform on node drop by dropping
into place of existing node instead of digger inventory.
--]]

nodecore.register_on_register_item(function(name, def)
		if def.type ~= "node" then return end
		local dip = def.drop_in_place
		if dip then
			if type(dip) ~= "table" then dip = {name = dip} end
			def.drop = def.drop or ""
			def.node_dig_prediction = def.node_dig_prediction or dip.name
			def.after_dig_node = def.after_dig_node or function(pos)
				minetest.set_node(pos, dip)
			end
		end
	end)
