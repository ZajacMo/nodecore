-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item(function(name, def)
		if def.oldnames then
			for _, v in pairs(def.oldnames) do
				if not minetest.registered_items[v] then
					minetest.register_alias(v, name)
				end
			end
			def.oldnames = nil
		end
	end)
