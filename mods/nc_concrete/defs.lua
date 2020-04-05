-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_concrete({
		description = "Aggregate",
		tile_powder = "nc_terrain_gravel.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)",
		tile_wet = "nc_terrain_stone.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
		sound = "nc_terrain_chompy",
		groups_powder = {crumbly = 2},
		craft_from = {groups = {gravel = true}},
		to_crude = "nc_terrain:cobble",
		to_washed = "nc_terrain:gravel",
		to_molded = "nc_terrain:stone"
	})
minetest.register_alias(modname .. ":wet_source", modname .. ":aggregate_wet_source")
minetest.register_alias(modname .. ":wet_flowing", modname .. ":aggregate_wet_flowing")

nodecore.register_concrete({
		description = "Render",
		tile_powder = "nc_terrain_sand.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)",
		tile_wet = "nc_terrain_sand.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
		sound = "nc_terrain_swishy",
		groups_powder = {crumbly = 1},
		swim_color = {r = 103, g = 103, b = 65},
		craft_from = {groups = {sand = true}},
		to_crude = "nc_terrain:sand",
		to_washed = "nc_terrain:sand",
		to_molded = "nc_terrain:sand"
	})

nodecore.register_concrete({
		description = "Adobe",
		tile_powder = "nc_terrain_dirt.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)",
		tile_wet = "nc_terrain_dirt.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
		sound = "nc_terrain_crunchy",
		groups_powder = {crumbly = 1},
		swim_color = {r = 103, g = 103, b = 65},
		craft_from = {groups = {dirt = true}},
		to_crude = "nc_terrain:dirt",
		to_washed = "nc_terrain:dirt",
		to_molded = "nc_terrain:dirt"
	})
