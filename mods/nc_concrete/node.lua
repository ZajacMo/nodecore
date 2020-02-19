-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":aggregate", {
		description = "Aggregate",
		tiles = {"nc_terrain_gravel.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)"},
		groups = {
			crumbly = 2,
			falling_node = 1,
			falling_repose = 1
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_chompy")
	})

local wettile = "nc_terrain_stone.png^(nc_fire_ash.png^("
.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)"
local wetdef = {
	description = "Wet Aggregate",
	tiles = {wettile},
	special_tiles = {wettile, wettile},
	liquid_viscosity = 15,
	liquid_renewable = false,
	liquid_range = 1,
	liquid_alternative_flowing = modname .. ":wet_flowing",
	liquid_alternative_source = modname .. ":wet_source",
	walkable = false,
	diggable = false,
	drowning = 1,
	post_effect_color = {a = 240, r = 32, g = 32, b = 32},
	sounds = nodecore.sounds("nc_terrain_chompy")
}
minetest.register_node(modname .. ":wet_source", nodecore.underride({
			liquidtype = "source"
		}, wetdef))
minetest.register_node(modname .. ":wet_flowing", nodecore.underride({
			drawtype = "flowingliquid",
			liquidtype = "flowing",
			paramtype2 = "flowingliquid"
		}, wetdef))
