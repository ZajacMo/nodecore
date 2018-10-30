local modname = minetest.get_current_modname()

local function regterrain(def)
	-- Fixup the name, inferring it from description, and adding mod
	-- prefix, if needed.
	local infername = def.description:gsub("%W", "_"):lower()
	def.name = def.name or modname .. ":" .. infername
	if def.name:gsub(":", "") == def.name then
		def.name = mod .. ":" .. def.name
	end

	-- Default some standard values.
	def.tiles = def.tiles or { def.name:gsub("%W", "_") .. ".png" }
	def.is_ground_content = true

	-- Default mapgen aliases.
	def.mapgen = def.mapgen or { infername }

	-- Register the node.
	minetest.register_node(def.name, def)

	-- Register any mapgen aliases.
	for k, v in pairs(def.mapgen) do
		minetest.register_alias("mapgen_" .. v, def.name)
	end
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
regterrain({
		description = "Water",
		mapgen = { "river_water_source", "water_source" },
		paramtype = "light",
		drawtype = "liquid",
		liquidtype = "source",
		alpha = 160,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drowning = 1,
		drop = ""
	})
regterrain({
		description = "Lava",
		mapgen = { "lava_source" },
		light_source = 13,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drowning = 1,
		damage_per_second = 8,
		drop = ""
	})
