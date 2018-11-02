local minetest = minetest
local nodecore = nodecore

nodecore.register_on_register_node(function(name, def)
		local dip = def.drop_in_place
		if dip then
			if type(dip) ~= "table" then dip = {name = dip} end
			def.drop = def.drop or ""
			def.after_dig_node = def.after_dig_node or function(pos)
				minetest.set_node(pos, dip)
			end
		end
	end)