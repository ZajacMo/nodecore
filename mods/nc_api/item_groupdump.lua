-- LUALOCALS < ---------------------------------------------------------
local io, minetest, nodecore, pairs, string, table
    = io, minetest, nodecore, pairs, string, table
local io_open, string_format, string_gsub, table_concat, table_sort
    = io.open, string.format, string.gsub, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

if not nodecore.infodump() then return end

--[[--

- Things marked (specific) are not intended to be used by new things not
already present in the game, and use in mod content is not supported.

- Things marked (api-managed) should not be applied manually but only
by using an appropriate API.

- Things marked (deprecated) are subject to removal and should neither
be used nor relied upon by mods.

--]]--

local groups = {
	alpha_glyph = "(specific) nc_writing glyphs",
	always_scalable = "nodes that can always be scaled even if they define on_rightclick",
	amalgam = "(specific) nc_igneous amalgamation",
	attached_node = "built-in: drops as item if node below is removed",
	canopy = "leaves or equivalent",
	charcoal = "(specific) nc_fire coal nodes",
	chisel = "metal shaft that can be used as a chisel with a mallet",
	choppy = "dig group: hatchets and adzes",
	cobble = "(specific) nc_terrain cobble",
	cobbley = "any \"cobble with filler\" type node (e.g. ores)",
	concrete_etchable = "(api-managed) concrete nodes that can be etched",
	concrete_flow = "(api-managed) concrete flowing liquids",
	concrete_powder = "(api-managed) concrete mix powders",
	concrete_source = "(api-managed) concrete liquid sources",
	concrete_wet = "(api-managed) concreted source or flowing liquid",
	container = "container grade; can only be placed inside containers of higher grade",
	coolant = "quenches nearby heated things",
	cracky = "dig group: picks and mattocks",
	crumbly = "dig group: spades, mattocks, and adzes",
	damage_radiant = "amount of radiant heat emitted that damages players slowly",
	damage_touch = "damage to deal player when punching or trying to pick up",
	dirt = "(specific) nc_terrain dirt and loose dirt",
	dirt_loose = "(specific) nc_terrain loose dirt",
	door = "door level of hinged panel",
	door_panel = "level of door that a panel would make if it were hinged",
	dungeon_mapgen = "dungeon nodes that are replaced with real ones after mapgen",
	dynamic_light = "light level of invisible dynamic lights from nc_api_active",
	ember = "(specific) fuel level of burning nc_fire embers",
	falling_node = "built-in: falls as a node if not supported below",
	falling_repose = "angle of repose for falling nodes, higher is steeper",
	fire_fuel = "for flammable nodes, convert into ember of this grade (1-8)",
	firestick = "can be rubbed against another firestick to make fire; success rate factor",
	flame = "(specific) open flame",
	flame_ambiance = "emits crackling fire ambiance (e.g. flames, torches)",
	flammable = "can catch fire; becomes ember if fire_fuel, or flame otherwise",
	flora = "decorative plants (nc_flora) or equivalent",
	flora_dry = "decorative plants that are dry (dried rushes, wilted flowers, all sedges)",
	flora_sedges = "(specific) sedge grass height",
	flower_living = "flowers that are still alive",
	flower_mutant = "flowers that are not found in mapgen",
	flower_wilted = "flowers that have died",
	grassable = "grass can spread onto this node (converting substrate to dirt)",
	gravel = "(specific) nc_terrain gravel",
	gravel_raked = "(specific) nc_writing raked gravel",
	green = "things containing significant amounts of living plant matter",
	hard_stone = "stratum of hard stone for stone, ores, and similar",
	igniter = "causes nearby flammable things to ignite",
	is_stack_only = "(specific) a bare item stack as a node",
	lava = "(specific) source or flowing pumwater",
	leaf_decay = "decays into its leaf_decay_as items if not connected to tree trunk",
	leafy = "(deprecated) loose leaves",
	lode_cobble = "(specific) lode cobble or loose lode cobble",
	lodey = "stone with lode in various states",
	log = "tree trunks and logs, can be split to planks",
	loose_repack = "loose nodes that self-repack over time",
	lux_cobble = "lux cobble that reacts to nearby lux cobble",
	lux_cobble_max = "lux cobble that produces lux flows",
	lux_emit = "things that emit lux radiation that irradiates players over time",
	lux_fluid = "(specific) lux source and flowing liquids",
	lux_hot = "lux cobble in a moderately excited but still subcritical state",
	lux_tool = "infused lode tools",
	metal_cube = "full cubes made of metal (lode cubes, crates)",
	metal_prill = "(specific) lode prills of various temper",
	metal_temper_annealed = "any lode thing in a slow-cooled and workable state",
	metal_temper_hot = "any lode thing in a heated and glowing",
	metal_temper_tempered = "any lode thing in a quenched and hardened state",
	metallic = "made of metal, efficiently absorbs lux radiation",
	moist = "water or other source of moisture esp. for plant cultivation",
	nc_scaling = "(specific) player-created climbing and light spots",
	nc_scaling_fx = "display black dust mote particles like scaling spots",
	not_in_creative_inventory = "built-in: not meaningful in nodecore",
	optic_check = "automatically run optic check callbacks",
	optic_source = "produces optic beams",
	rakey = "is a rake tool, can rake line patterns into sand/gravel",
	rock = "all non-glassy rocky/stony things, including stone, cobble, brick, etc",
	sand = "(specific) nc_terrain sand",
	sand_raked = "(specific) nc_writing raked sand",
	scaling_time = "percentage time it takes to scale this node",
	silica = "any glass, can be ground back to sand",
	silica_clear = "any clear glass, grinds to crude, passes light",
	silica_lens = "equivalent to only half a node of sand by weight",
	silica_molten = "(specific) nc_optics molten glass",
	silica_prism = "glass prism in any state",
	smoothstone = "smooth stone that can be chiseled to bricks",
	snappy = "dig group: by hand",
	soil = "dirt that provides nutrients to plant growth",
	sponge = "(specific) nc_sponge sponges",
	stack_as_node = "single items landing on ground should be placed as node",
	stone = "variants of smooth stone, including ones with inclusions (ore)",
	stone_bricks = "smooth stone that's been chiseled into bricks",
	storebox = "storage containers (e.g. shelves, cases, crates)",
	support_falling = "falling_nodes can rest on it even if not walkable",
	torch_lit = "(specific) lit torches, subject to various events/timers",
	totable = "nodes that can be packed up into a tote",
	tote = "totes and tote handles",
	visinv = "display nodecore.stack_get() stack as an entity in node",
	water = "water, artificial water, or equivalent",
}

minetest.after(0, function()
		for _, v in pairs(minetest.registered_items) do
			for k in pairs(v.groups or {}) do
				groups[k] = groups[k] or ""
			end
		end
		local sorted = {}
		for k in pairs(groups) do sorted[#sorted + 1] = k end
		table_sort(sorted)
		for i = 1, #sorted do
			local k = sorted[i]
			sorted[i] = (string_gsub(string_gsub(k, "%w", ""), "_", "")
				~= "" and string_format("[% q]", k) or k) .. " = "
			.. string_format("%q", groups[k]) .. ","
		end
		local f = io_open(minetest.get_worldpath() .. "/groups.txt", "wb")
		f:write(table_concat(sorted, "\n"))
		f:close()
	end)
