local minetest = minetest
local modname = minetest.get_current_modname()

local function infername(def)
	def.name = def.name or def.description:gsub("%W", "_"):lower()
	def.fullname = modname .. ":" .. def.name
end

local function regterrain(def)
	infername(def)

	def.tiles = def.tiles or { def.fullname:gsub("%W", "_") .. ".png" }
	def.is_ground_content = true

	def.mapgen = def.mapgen or { def.name }

	print(dump(def))
	minetest.register_node(def.fullname, def)

	for k, v in pairs(def.mapgen) do
		minetest.register_alias("mapgen_" .. v, def.fullname)
	end
end

local function clone(t) return minetest.deserialize(minetest.serialize(t)) end

local function regliquid(def)
	infername(def)
	def.tiles = def.tiles or { def.fullname:gsub("%W", "_") .. ".png" }

	def.liquid_alternative_flowing = def.fullname .. "_flowing"
	def.liquid_alternative_source = def.fullname .. "_source"

	print(dump(def))
	
	local t = clone(def)
	t.name = t.name .. "_source"
	regterrain(t)

	t = clone(def)
	t.name = t.name .. "_flowing"
	t.mapgen = nil
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

minetest.register_alias("mapgen_snow", "air")
minetest.register_alias("mapgen_snowblock", "air")
minetest.register_alias("mapgen_junglegrass", "air")

regterrain({
		description = "Dirt",
		mapgen = {
			"dirt",
			"ice",
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
		}
	})
regterrain({
		description = "Gravel",
		groups = { falling_node = 1 },
	})
regterrain({
		description = "Sand",
		groups = { falling_node = 1 },
		mapgen = {
			"sand",
			"clay",
			"desert_sand" 
		},
	})
regterrain({
		description = "Tree",
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		mapgen = {
			"tree",
			"jungletree",
			"pine_tree"
		}
	})
regterrain({
		description = "Leaves",
		paramtype = "light",
		mapgen = {
			"leaves",
			"apple",
			"jungleleaves",
			"pine_needles"
		}
	})

regliquid({
		description = "Water",
		mapgen = { "river_water_source", "water_source" },
		paramtype = "light",
		drawtype = "liquid",
		liquidtype = "source",
		liquid_viscosity = 1,
		liquid_renewable = false,
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
		drawtype = "liquid",
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
