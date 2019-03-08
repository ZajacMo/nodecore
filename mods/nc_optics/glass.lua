-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":glass", {
		description = "Clear Glass",
		drawtype = "glasslike_framed_optional",
		tiles = {
			modname .. "_glass_glare.png^" .. modname .. "_glass_edges.png",
			modname .. "_glass_glare.png"
		},
		groups = {
			cracky = 3
		},
		sunlight_propagates = true,
		paramtype = "light"
	})

minetest.register_node(modname .. ":glass_opaque", {
		description = "Chromatic Glass",
		tiles = { modname .. "_glass_frost.png" },
		groups = {
			cracky = 3
		},
		paramtype = "light"
	})

local molttxr = "nc_terrain_lava.png^nc_optics_glass_glare.png"
local moltdef = {
	description = "Molten Glass",
	drawtype = "liquid",
	tiles = { molttxr },
	special_tiles = { molttxr, molttxr },
	paramtype = "light",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 2,
	light_source = 2,
	walkable = false,
	diggable = false,
	buildable_to = false,
	drowning = 1,
	on_punch = nodecore.node_punch_hurt,
	damage_per_second = 4,
	drop = "",
	groups = { igniter = 1 },
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	liquid_alternative_flowing = modname .. ":glass_hot_flowing",	
	liquid_alternative_source = modname .. ":glass_hot_source"
}

minetest.register_node(modname .. ":glass_hot_source",
	nodecore.underride({
			liquidtype = "source"
			}, moltdef))
minetest.register_node(modname .. ":glass_hot_flowing",
	nodecore.underride({
			liquidtype = "flowing",
			drawtype = "flowingliquid",
			paramtype2 = "flowingliquid"
			}, moltdef))
