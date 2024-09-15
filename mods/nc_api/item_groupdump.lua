-- LUALOCALS < ---------------------------------------------------------
local io, minetest, nodecore, pairs, setmetatable, string, table
    = io, minetest, nodecore, pairs, setmetatable, string, table
local io_open, string_format, string_gsub, table_concat, table_sort
    = io.open, string.format, string.gsub, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

if not nodecore.infodump("group") then return end

--[[--

- Things marked (specific) are not intended to be used by new things not
already present in the game, and use in mod content is not supported.

- Things marked (api-managed) should not be applied manually but only
by using an appropriate API.

- Things marked (deprecated) are subject to removal and should neither
be used nor relied upon by mods.

--]]--

local groups = {
	activates_lens = "always activates optics lenses, regardless of light_source",
	adobe = "any node made of adobe (patterned, bricked, etc)",
	alpha_glyph = "(specific) nc_writing glyphs",
	always_scalable = "nodes that can always be scaled even if they define on_rightclick",
	amalgam = "(specific) nc_igneous amalgamation",
	attached_node = "built-in: drops as item if node below is removed",
	canopy = "leaves or equivalent",
	charcoal = "(specific) nc_fire coal nodes",
	cheat = "having posession of this item represents a form of cheat (e.g. admin tool)",
	chisel = "metal shaft that can be used as a chisel with a mallet",
	choppy = "dig group: hatchets and adzes",
	cloudstone = "(specific) concrete cloudstone",
	coalstone = "any node made of tarstone (patterned, bricked, etc)",
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
	cuddly = "dig group: ONLY player hands",
	damage_pickup = "damage to deal player when trying to pick up",
	damage_radiant = "amount of radiant heat emitted that damages players slowly",
	damage_touch = "damage to deal player when punching or trying to pick up",
	dirt = "(specific) nc_terrain dirt and loose dirt",
	dirt_loose = "(specific) nc_terrain loose dirt",
	dirt_raked = "(specific) raked nc_terrain dirt",
	door = "door level of hinged panel",
	door_operate_sound_volume = "override door operate sound percentage",
	door_panel = "level of door that a panel would make if it were hinged",
	dungeon_mapgen = "dungeon nodes that are replaced with real ones after mapgen",
	dynamic_light = "light level of invisible dynamic lights from nc_api_active",
	ember = "(specific) fuel level of burning nc_fire embers",
	falling_mapgen_ignore = "falling nodes that are ignored by mapgen falling node removal",
	falling_node = "built-in: falls as a node if not supported below",
	falling_repose = "angle of repose for falling nodes, higher is steeper",
	fire_fuel = "for flammable nodes, convert into ember of this grade (1-8)",
	firestick = "can be rubbed against another firestick to make fire; success rate factor",
	flame = "(specific) open flame",
	flame_ambiance = "emits crackling fire ambiance (e.g. flames, torches)",
	flammable = "can catch fire; becomes ember if fire_fuel, or flame otherwise",
	float = "built-in: falling node lands on top of liquids",
	flora = "decorative plants (nc_flora) or equivalent",
	flora_dry = "decorative plants that are dry (dried rushes, wilted flowers, all sedges)",
	flora_sedges = "(specific) sedge grass height",
	flower_living = "flowers that are still alive",
	flower_mutant = "flowers that are not found in mapgen",
	flower_wilted = "flowers that have died",
	grass = "(specific) nc_terrain dirt_with_grass",
	grassable = "grass can spread onto this node (converting substrate to dirt)",
	gravel = "(specific) nc_terrain gravel",
	gravel_raked = "(specific) nc_writing raked gravel",
	green = "things containing significant amounts of living plant matter",
	hard_stone = "stratum of hard stone for stone, ores, and similar",
	humus = "(specific) nc_tree humus",
	humus_raked = "(specific) raked nc_tree humus",
	igniter = "causes nearby flammable things to ignite",
	is_stack_only = "(specific) a bare item stack as a node",
	lava = "(specific) source or flowing pumwater",
	leaf_decay = "decays into its leaf_decay_as items if not connected to tree trunk",
	leaf_decay_support = "nodes that stop leaves from decaying (tree trunks)",
	leaf_decay_transmit = "nodes that transmit leaf decay stoppage through them (leaves)",
	leafy = "(deprecated) loose leaves",
	lens_glow_start = "(specific) glowing lenses in warm-up state",
	lode_cobble = "(specific) lode cobble or loose lode cobble",
	lode_cube = "full cubes made of lode (lode cubes, crates)",
	lode_prill = "(specific) lode prills of various temper",
	lode_temper_annealed = "any lode thing in a slow-cooled and workable state",
	lode_temper_hot = "any lode thing in a heated and glowing",
	lode_temper_tempered = "any lode thing in a quenched and hardened state",
	lodey = "stone with lode in various states",
	log = "tree trunks and logs, can be split to planks",
	loose_repack = "loose nodes that self-repack over time",
	lux_absorb = "lux radiation absorption proportion in 64ths of total",
	lux_cobble = "lux cobble that reacts to nearby lux cobble",
	lux_cobble_max = "lux cobble that produces lux flows",
	lux_emit = "things that emit lux radiation that irradiates players over time",
	lux_fluid = "(specific) lux source and flowing liquids",
	lux_hot = "lux cobble in a moderately excited but still subcritical state",
	lux_rock = "lux rock in smooth-stone or cobble form (for ore hints)",
	lux_scatter = "lux radiation scattering probability in 64ths",
	lux_tool = "infused lode tools",
	metallic = "made of metal, efficiently absorbs lux radiation",
	moist = "water or other source of moisture esp. for plant cultivation",
	nc_api_rotate_above = "rotate when in pointed_thing above location",
	nc_api_rotate_under = "rotate when in pointed_thing under location",
	nc_concrete_etched = "(api-managed) any non-pliant concrete node with etched patterns",
	nc_concrete_pattern_bindy = "(api-managed) any type of concrete with a bindy pattern",
	nc_concrete_pattern_boxy = "(api-managed) any type of concrete with a boxy pattern",
	nc_concrete_pattern_bricky = "(api-managed) any type of concrete with a bricky pattern",
	nc_concrete_pattern_hashy = "(api-managed) any type of concrete with a hashy pattern",
	nc_concrete_pattern_horzy = "(api-managed) any type of concrete with a horzy pattern",
	nc_concrete_pattern_iceboxy = "(api-managed) any type of concrete with a iceboxy pattern",
	nc_concrete_pattern_vermy = "(api-managed) any type of concrete with a vermy pattern",
	nc_concrete_pattern_verty = "(api-managed) any type of concrete with a verty pattern",
	nc_concrete_pliant = "(api-managed) any type of concrete in a pliant state",
	nc_door_scuff_opacity = "override opacity of scuff texture when making door",
	nc_doors_pummel_first = "test for pummel recipes before dig when used by door",
	nc_lantern = "(specific) chargeable lux lantern",
	nc_lantern_charged = "(specific) lux lantern with significant charge level",
	nc_lantern_full = "(specific) lux lantern at full charge",
	nc_scaling = "(specific) player-created climbing and light spots",
	nc_scaling_fx = "display black dust mote particles like scaling spots",
	not_in_creative_inventory = "built-in: not meaningful in nodecore",
	optic_check = "automatically run optic check callbacks",
	optic_gluable = "any optic that can be glued in place with an eggcorn",
	optic_lens = "equivalent/replaceable by a lens when held in inventory",
	optic_lens_emit = "a lens emitting a full-intensity beam (firestart, ablate)",
	optic_opaque = "force node to be opaque to optic beams",
	optic_source = "produces optic beams",
	optic_transparent = "force node to be transparent to optic beams",
	peat_grindable_item = "stack of 8 can be ground into peat automatically",
	peat_grindable_node = "single one can be ground into peat automatically",
	pumice = "(specific) equivalent to nodecore pumice",
	pumice_no_support = "does not provide support to pumice structures",
	pumice_support = "provides support to pumice structures",
	radiant_opaque = "force radiant heat damage to be blocked",
	radiant_transparent = "force radiant heat damage to pass through",
	raked = "a node whose surface has been raked",
	rakey = "is a rake tool, can rake line patterns into sand/gravel",
	rock = "all non-glassy rocky/stony things, including stone, cobble, brick, etc",
	sand = "(specific) nc_terrain sand",
	sand_raked = "(specific) nc_writing raked sand",
	sandstone = "any node made of sandstone (patterned, bricked, etc)",
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
	storebox_sealed = "storage container that's airtight (sponges) if open sides covered",
	storebox_sealed_always = "storage container that's airtight (sponges) always",
	support_falling = "falling_nodes can rest on it even if not walkable",
	thumpy = "dig group: mallets and hand",
	torch_lit = "(specific) lit torches, subject to various events/timers",
	totable = "nodes that can be packed up into a tote",
	tote = "totes and tote handles",
	visinv = "display nodecore.stack_get() stack as an entity in node",
	visinv_hidden = "hide visinv ent; it's baked into the node model already",
	water = "water, artificial water, or equivalent",
	witness_opaque = "force things to be treated as opaque for hint witnessing",
	witness_transparent = "force things to be treated as transparent for hint witnessing",
}

local dumpqueued

local function dumpfile()
	dumpqueued = nil
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
	nodecore.log("info", "dumped groups.txt")
end

dumpqueued = true
minetest.after(0, dumpfile)

local function learngroup(name)
	if groups[name] then return end
	groups[name] = ""
	if dumpqueued then return end
	dumpqueued = true
	minetest.after(0, dumpfile)
end

local oldgetgroup = minetest.get_item_group
function minetest.get_item_group(name, group, ...)
	learngroup(group)
	return oldgetgroup(name, group, ...)
end

minetest.after(0, function()
		for _, def in pairs(minetest.registered_items) do
			for k in pairs(def.groups) do
				groups[k] = groups[k] or ""
			end
			setmetatable(def.groups, {
					__index = function(_, k)
						learngroup(k)
					end
				})
		end
	end)
