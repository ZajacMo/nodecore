-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, type
    = ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function regterrain(def)
	def.name = def.name or def.description:gsub("%W", "_"):lower()
	def.fullname = modname .. ":" .. def.name

	def.tiles = def.tiles or {def.fullname:gsub("%W", "_") .. ".png"}
	def.is_ground_content = true

	if def.liquidtype then
		def.liquid_alternative_flowing = def.fullname .. "_flowing"
		def.liquid_alternative_source = def.fullname .. "_source"
		def.fullname = def.fullname .. "_" .. def.liquidtype
		def.special_tiles = def.special_tiles or {def.tiles[1], def.tiles[1]}
	end

	def.mapgen = def.mapgen or {def.name}

	minetest.register_node(def.fullname, def)

	for _, v in pairs(def.mapgen) do
		minetest.register_alias("mapgen_" .. v, def.fullname)
	end
end

local function clone(t)
	local c = minetest.deserialize(minetest.serialize(t))
	for k, v in pairs(t) do
		if type(v) == "function" then c[k] = v end
	end
	return c
end

local function regliquid(def)
	local t = clone(def)
	t.drawtype = "liquid"
	t.liquidtype = "source"
	regterrain(t)

	t = clone(def)
	t.mapgen = {}
	t.drawtype = "flowingliquid"
	t.liquidtype = "flowing"
	t.paramtype2 = "flowingliquid"
	regterrain(t)
end

local strata = {}
regterrain({
		description = "Stone",
		mapgen = {
			"stone",
			"stone_with_coal",
			"stone_with_iron",
			"desert_stone",
			"sandstone",
			"mese",
		},
		silktouch = false,
		groups = {
			stone = 1,
			rock = 1,
			cracky = 2
		},
		drop_in_place = modname .. ":cobble",
		strata = strata,
		sounds = nodecore.sounds("nc_terrain_stony")
	})
strata[1] = modname .. ":stone"
for i = 1, nodecore.hard_stone_strata do
	regterrain({
			name = "hard_stone_" .. i,
			description = "Stone",
			tiles = {nodecore.hard_stone_tile(i)},
			silktouch = false,
			groups = {
				stone = i,
				rock = i,
				cracky = i + 2,
				hard_stone = i
			},
			drop_in_place = modname .. ((i > 1)
				and (":hard_stone_" .. (i - 1)) or ":stone"),
			sounds = nodecore.sounds("nc_terrain_stony")
		})
	strata[i + 1] = modname .. ":hard_stone_" .. i
end

regterrain({
		description = "Cobble",
		tiles = {modname .. "_gravel.png^" .. modname .. "_cobble.png"},
		mapgen = {
			"sandstonebrick",
			"stair_sandstone_block",
			"cobble",
			"stair_cobble",
			"stair_desert_stone",
			"mossycobble"
		},
		groups = {
			cobble = 1,
			rock = 1,
			cracky = 1
		},
		alternate_loose = {
			repack_level = 2,
			groups = {
				cracky = 0,
				crumbly = 2,
				falling_repose = 3
			},
			sounds = nodecore.sounds("nc_terrain_chompy")
		},
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony")
	})

for _, v in ipairs({
		"snow",
		"snowblock",
		"junglegrass",
		"tree",
		"jungletree",
		"pine_tree",
		"leaves",
		"apple",
		"jungleleaves",
		"pine_needles"
	}) do
	minetest.register_alias("mapgen_" .. v, "air")
end

regterrain({
		description = "Dirt",
		alternate_loose = {
			groups = {
				dirt_loose = 1,
				falling_repose = 2,
				soil = 2
			}
		},
		mapgen = {
			"dirt",
			"ice",
		},
		groups = {
			dirt = 1,
			crumbly = 1,
			soil = 1
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_crunchy")
	})
regterrain({
		name = "dirt_with_grass",
		description = "Grass",
		tiles = {
			modname .. "_grass_top.png",
			modname .. "_dirt.png",
			modname .. "_dirt.png^" .. modname .. "_grass_side.png"
		},
		mapgen = {
			"dirt_with_grass",
			"dirt_with_snow"
		},
		groups = {
			crumbly = 2,
			soil = 1,
			green = 1
		},
		drop_in_place = modname .. ":dirt",
		sounds = nodecore.sounds("nc_terrain_grassy")
	})
regterrain({
		description = "Gravel",
		alternate_loose = {
			groups = {
				crumbly = 2,
				falling_repose = 2
			}
		},
		groups = {
			gravel = 1,
			crumbly = 1,
			falling_node = 1
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_chompy")
	})
regterrain({
		description = "Sand",
		alternate_loose = {
			groups = {
				falling_repose = 1
			}
		},
		groups = {
			sand = 1,
			crumbly = 1,
			falling_node = 1
		},
		mapgen = {
			"sand",
			"clay",
			"desert_sand"
		},
		crush_damage = 0.5,
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

local function anim(name, len)
	return {
		name = name,
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = len
		}
	}
end

regliquid({
		description = "Water",
		mapgen = {"river_water_source", "water_source"},
		tiles = {anim(modname .. "_water.png", 4)},
		special_tiles = {
			anim(modname .. "_water_flow.png", 4),
			anim(modname .. "_water_flow.png", 4)
		},
		paramtype = "light",
		liquid_viscosity = 1,
		liquid_renewable = true,
		alpha = 192,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drowning = 1,
		drop = "",
		groups = {coolant = 1, water = 2, moist = 2},
		post_effect_color = {a = 103, r = 30, g = 76, b = 90},
		sounds = nodecore.sounds("nc_terrain_watery")
	})
regliquid({
		name = "lava",
		tiles = {anim(modname .. "_lava.png", 8)},
		special_tiles = {
			anim(modname .. "_lava_flow.png", 8),
			anim(modname .. "_lava_flow.png", 8)
		},
		description = "Molten Rock",
		mapgen = {"lava_source"},
		paramtype = "light",
		liquid_viscosity = 7,
		liquid_renewable = false,
		light_source = 13,
		walkable = false,
		diggable = false,
		buildable_to = true,
		drowning = 1,
		damage_per_second = 8,
		on_punch = nodecore.node_punch_hurt,
		drop = "",
		groups = {igniter = 1, lava = 2},
		post_effect_color = {a = 191, r = 255, g = 64, b = 0},
		sounds = nodecore.sounds("nc_terrain_bubbly")
	})
