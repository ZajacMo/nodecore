-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local sandname = "nc_terrain:sand"
local sanddef = minetest.registered_items[sandname] or {}
for i = 1, 6 do
	minetest.register_node(modname .. ":sand_with_raking_" .. i,
		nodecore.underride({
				description = "Raked Sand",
				tiles = {
					sanddef.tiles[1] .. "^" .. modname
					.. "_raking_" .. i .. ".png",
					sanddef.tiles[1]},
				paramtype2 = "facedir",
				on_place = function(itemstack, placer, pointed_thing)
					return minetest.rotate_and_place(
						itemstack, placer, pointed_thing,
						false, {force_floor = true})
				end,
				falling_replacement = sandname,
			}, sanddef))
end
