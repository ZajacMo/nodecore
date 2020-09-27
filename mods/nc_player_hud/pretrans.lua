-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs
    = nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item({
		retroactive = true,
		func = function(_, def)
			if def.description then
				nodecore.translate_inform(def.description)
			end
			if def.meta_descriptions then
				for _, d in pairs(def.meta_descriptions) do
					nodecore.translate_inform(d)
				end
			end
		end
	})
