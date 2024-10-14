-- LUALOCALS < ---------------------------------------------------------
local nc, pairs
    = nc, pairs
-- LUALOCALS > ---------------------------------------------------------

nc.register_on_register_item({
		retroactive = true,
		func = function(_, def)
			if def.description then
				nc.translate_inform(def.description)
			end
			if def.meta_descriptions then
				for _, d in pairs(def.meta_descriptions) do
					nc.translate_inform(d)
				end
			end
		end
	})
