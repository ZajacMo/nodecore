-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

minetest.after(0, function()
		for _, v in pairs(minetest.registered_items) do
			if v.description then
				nodecore.translate_inform(v.description)
			end
			if v.meta_descriptions then
				for _, d in pairs(v.meta_descriptions) do
					nodecore.translate_inform(d)
				end
			end
		end
	end)
