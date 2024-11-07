-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs
    = core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

nc.register_on_register_item(function(name, def)
		if def.oldnames then
			for _, v in pairs(def.oldnames) do
				if not core.registered_items[v] then
					core.register_alias(v, name)
				end
			end
			def.oldnames = nil
		end
	end)
