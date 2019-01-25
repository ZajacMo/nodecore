-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item(function(name, def)
		if def.oldnames then
			for k, v in pairs(def.oldnames) do
				minetest.register_alias(v, name)
			end
		end
	end)
