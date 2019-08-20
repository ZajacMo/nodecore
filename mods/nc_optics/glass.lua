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
			silica = 1,
			silica_clear = 1,
			cracky = 3
		},
		sunlight_propagates = true,
		paramtype = "light",
		sounds = nodecore.sounds("nc_optics_glassy")
	})

minetest.register_node(modname .. ":glass_opaque", {
		description = "Chromatic Glass",
		tiles = { modname .. "_glass_frost.png" },
		groups = {
			silica = 1,
			cracky = 3
		},
		paramtype = "light",
		sounds = nodecore.sounds("nc_optics_glassy")
	})

minetest.register_node(modname .. ":glass_crude", {
		description = "Crude Glass",
		drawtype = "glasslike_framed_optional",
		tiles = {
			modname .. "_glass_crude.png^" .. modname .. "_glass_edges.png",
			modname .. "_glass_crude.png"
		},
		paramtype = "light",
		groups = {
			silica = 1,
			falling_node = 1,
			crumbly = 2
		},	
		sounds = nodecore.sounds("nc_terrain_crunchy")
	})

minetest.register_node(modname .. ":glass_float", {
		description = "Float Glass",
		drawtype = "glasslike_framed_optional",
		tiles = {
			modname .. "_glass_float.png^" .. modname .. "_glass_edges.png",
			modname .. "_glass_float.png"
		},
		propagates_sunlight = true,
		paramtype = "light",
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 3
		},	
		sounds = nodecore.sounds("nc_optics_glassy")
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
	light_source = 4,
	walkable = false,
	diggable = false,
	buildable_to = false,
	drowning = 1,
	on_punch = nodecore.node_punch_hurt,
	damage_per_second = 4,
	drop = "",
	groups = { igniter = 1, silica = 1 },
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	liquid_alternative_flowing = modname .. ":glass_hot_flowing",	
	liquid_alternative_source = modname .. ":glass_hot_source",
	sounds = nodecore.sounds("nc_terrain_bubbly")
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

nodecore.register_ambiance({
		label = "Glass Source Ambiance",
		nodenames = {modname .. ":glass_hot_source"},
		neigbors = {"air"},
		interval = 1,
		chance = 10,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
nodecore.register_ambiance({
		label = "Glass Flow Ambiance",
		nodenames = {modname .. ":glass_hot_flowing"},
		neigbors = {"air"},
		interval = 1,
		chance = 10,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
