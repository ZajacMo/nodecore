-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":glass", {
		description = "Clear Glass",
		drawtype = "glasslike_framed",
		tiles = {
			modname .. "_glass_glare.png^" .. modname .. "_glass_edges.png",
			modname .. "_glass_glare.png"
		},
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 3,
			scaling_time = 300
		},
		sunlight_propagates = true,
		paramtype = "light",
		sounds = nc.sounds("nc_optics_glassy"),
		mapcolor = {r = 255, g = 255, b = 255, a = 64},
	})

core.register_node(modname .. ":glass_opaque", {
		description = "Chromatic Glass",
		tiles = {modname .. "_glass_frost.png"},
		groups = {
			silica = 1,
			cracky = 3,
			scaling_time = 300
		},
		paramtype = "light",
		sounds = nc.sounds("nc_optics_glassy"),
		mapcolor = {r = 139, g = 187, b = 212},
	})

core.register_node(modname .. ":glass_crude", {
		description = "Crude Glass",
		drawtype = "glasslike_framed",
		tiles = {
			modname .. "_glass_crude.png^" .. modname .. "_glass_edges.png",
			modname .. "_glass_crude.png"
		},
		paramtype = "light",
		groups = {
			silica = 1,
			falling_node = 1,
			falling_mapgen_ignore = 1,
			crumbly = 2,
			scaling_time = 150
		},
		sounds = nc.sounds("nc_terrain_crunchy"),
		mapcolor = {r = 255, g = 255, b = 255, a = 128},
	})

core.register_node(modname .. ":glass_float", {
		description = "Float Glass",
		drawtype = "glasslike_framed",
		tiles = {
			modname .. "_glass_edges.png",
			"[combine:16x16"
		},
		sunlight_propagates = true,
		paramtype = "light",
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 3,
			scaling_time = 300
		},
		sounds = nc.sounds("nc_optics_glassy"),
		mapcolor = {r = 255, g = 255, b = 255, a = 16},
	})

local function anim(name, len)
	return {
		name = name,
		animation = {
			["type"] = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = len
		}
	}
end

local animglass = ""
for i = 0, 31 do
	animglass = animglass .. ":0," .. (i * 16) .. "=(nc_optics_glass_sparkle.png\\^[resize\\:16x16)"
end
animglass = "^[resize:16x512^[multiply:#c06000^([combine:16x512"
.. animglass .. "^[multiply:#ffc080)"
local molttxr = anim("nc_terrain_lava.png" .. animglass, 8)
local flowtxr = anim("nc_terrain_lava_flow.png" .. animglass, 8)

local moltdef = {
	description = "Molten Glass",
	drawtype = "liquid",
	tiles = {molttxr},
	special_tiles = {flowtxr, flowtxr},
	paramtype = "light",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 2,
	light_source = 4,
	walkable = false,
	buildable_to = false,
	drowning = 2,
	damage_per_second = 3,
	drop = "",
	groups = {
		igniter = 1,
		silica = 1,
		silica_molten = 1,
		damage_touch = 1,
		damage_radiant = 3,
		cheat = 1
	},
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	liquid_alternative_flowing = modname .. ":glass_hot_flowing",
	liquid_alternative_source = modname .. ":glass_hot_source",
	sounds = nc.sounds("nc_terrain_bubbly"),
	mapcolor = {r = 238, g = 76, b = 0},
}

core.register_node(modname .. ":glass_hot_source",
	nc.underride({
			liquidtype = "source"
		}, moltdef))
core.register_node(modname .. ":glass_hot_flowing",
	nc.underride({
			liquidtype = "flowing",
			drawtype = "flowingliquid",
			paramtype2 = "flowingliquid"
		}, moltdef))

nc.register_ambiance({
		label = "glass source ambiance",
		nodenames = {modname .. ":glass_hot_source"},
		neigbors = {"air"},
		interval = 1,
		chance = 10,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
nc.register_ambiance({
		label = "glass flow ambiance",
		nodenames = {modname .. ":glass_hot_flowing"},
		neigbors = {"air"},
		interval = 1,
		chance = 10,
		sound_name = "nc_terrain_bubbly",
		sound_gain = 0.2
	})
