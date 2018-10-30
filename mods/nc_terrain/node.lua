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
		"mese",
		"cobble",
		"mossycobble"
	},
})
regterrain({ description = "Dirt" })
regterrain({
	description = "Dirt with Grass",
	tiles = {
		modname .. "_grass_top.png",
		modname .. "_dirt.png",
		modname .. "_dirt.png^" .. modname .. "_grass_side.png"
 	},
})
regterrain({
	description = "Gravel",
	groups = { falling_node = 1 },
})
regterrain({
	description = "Sand",
	groups = { falling_node = 1 },
	mapgen = { "sand", "clay" },
})
regterrain({
	description = "Tree",
	tiles = {
		modname .. "_tree_top.png",
		modname .. "_tree_top.png",
		modname .. "_tree_side.png"
	},
})
regterrain({
	description = "Leaves",
	paramtype = "light",
})
regterrain({
	description = "Water",
	mapgen = { "water_source" },
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
