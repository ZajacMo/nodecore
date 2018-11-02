local minetest = minetest
local modname = minetest.get_current_modname()

local function regterrain(def)
	def.name = def.name or def.description:gsub("%W", "_"):lower()
	def.fullname = modname .. ":" .. def.name

	def.tiles = def.tiles or { def.fullname:gsub("%W", "_") .. ".png" }
	def.is_ground_content = true

	if def.liquidtype then
		def.liquid_alternative_flowing = def.fullname .. "_flowing"		
		def.liquid_alternative_source = def.fullname .. "_source"
		def.fullname = def.fullname .. "_" .. def.liquidtype
		def.special_tiles = def.special_tiles or { def.tiles[1], def.tiles[1] }
	end

	def.mapgen = def.mapgen or { def.name }

	minetest.register_node(def.fullname, def)

	for k, v in pairs(def.mapgen) do
		minetest.register_alias("mapgen_" .. v, def.fullname)
	end
end

local function clone(t) return minetest.deserialize(minetest.serialize(t)) end

local function regliquid(def)
	local t = clone(def)
	t.drawtype = "liquid"
	t.liquidtype = "source"
	regterrain(t)

	t = clone(def)
	t.mapgen = { }
	t.drawtype = "flowingliquid"
	t.liquidtype = "flowing"
	t.paramtype2 = "flowingliquid"
	regterrain(t)
end

-- Register standard mapgen node types.
regterrain({
		description = "Stone",
		mapgen = {
			"stone",
			"stone_with_coal",
			"stone_with_iron",
			"desert_stone",
			"sandstone",
			"sandstonebrick",
			"stair_sandstone_block",
			"mese",
			"cobble",
			"stair_cobble",
			"stair_desert_stone",
			"mossycobble"
		},
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
		mapgen = {
			"dirt",
			"ice",
		},
		groups = {
			crumbly = 3
		}
	})
regterrain({
		description = "Dirt with Grass",
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
			crumbly = 3
		},
		drop = modname .. ":dirt"
	})
regterrain({
		description = "Gravel",
		groups = { 
			crumbly = 1,
			falling_node = 1
		},
	})
regterrain({
		description = "Sand",
		groups = { 
			crumbly = 3,
			falling_node = 1 
		},
		mapgen = {
			"sand",
			"clay",
			"desert_sand" 
		},
	})

regliquid({
		description = "Water",
		mapgen = { "river_water_source", "water_source" },
		paramtype = "light",
		liquid_viscosity = 1,
		liquid_renewable = true,
		alpha = 160,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drowning = 1,
		drop = "",
		post_effect_color = {a = 103, r = 30, g = 76, b = 90}
	})
regliquid({
		description = "Lava",
		mapgen = { "lava_source" },
		paramtype = "light",
		liquid_viscosity = 7,
		liquid_renewable = false,
		light_source = 13,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drowning = 1,
		damage_per_second = 8,
		drop = "",
		post_effect_color = {a = 191, r = 255, g = 64, b = 0}
	})
