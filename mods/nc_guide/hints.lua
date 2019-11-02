-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local addhint = nodecore.addhint

------------------------------------------------------------------------
-- SCALING

addhint("scale a sheer wall", "scale sheer walls")
addhint("scale a sheer overhang", "scale sheer ceilings")

------------------------------------------------------------------------
-- TERRAIN

addhint("dig up dirt",
	"dig:nc_terrain:dirt_loose"
)

addhint("dig up gravel",
	"dig:nc_terrain:gravel_loose",
	"toolcap:crumbly:2"
)

addhint("dig up sand",
	"dig:nc_terrain:sand_loose"
)

addhint("dig up stone",
	"dig:nc_terrain:cobble_loose",
	"toolcap:cracky:2"
)

addhint("find deep stone strata",
	"group:hard_stone",
	"nc_terrain:cobble_loose"
)

addhint("find molten rock",
	"group:lava",
	"nc_terrain:cobble_loose"
)

------------------------------------------------------------------------
-- SPONGE

addhint("find a sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("harvest a sponge",
	"inv:nc_sponge:sponge_wet",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("extract living sponge from colony center",
	"inv:nc_sponge:sponge_living",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("dry out a sponge",
	"nc_sponge:sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("squeeze out a sponge",
	"squeeze sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

------------------------------------------------------------------------
-- TREE

addhint("find dry (loose) leaves",
	"nc_tree:leaves_loose"
)

addhint("find an eggcorn",
	"nc_tree:eggcorn"
)

addhint("plant an eggcorn",
	"eggcorn planting",
	{"nc_tree:eggcorn", "nc_terrain:dirt_loose"}
)

addhint("see a tree grow",
	"tree growth",
	"eggcorn planting"
)

addhint("find a stick",
	"nc_tree:stick"
)

addhint("cut down a tree",
	"dig:nc_tree:tree",
	"toolcap:choppy:2"
)

addhint("dig up a tree stump",
	"dig:nc_tree:root",
	"toolcap:choppy:4"
)

addhint("pack leaves into peat",
	"nc_tree:peat",
	"nc_tree:leaves_loose"
)

addhint("ferment peat into humus",
	"nc_tree:humus",
	"nc_tree:peat"
)

------------------------------------------------------------------------
-- FIRE

addhint("make fire by rubbing sticks together",
	"stick fire starting",
	"nc_tree:stick"
)

addhint("find ash",
	"nc_fire:ash",
	"stick fire starting"
)

addhint("find charcoal",
	"group:charcoal",
	"stick fire starting"
)

addhint("chop up charcoal",
	"nc_fire:lump_coal",
	"group:charcoal"
)

addhint("pack high-quality charcoal",
	"nc_fire:coal" .. nodecore.fire_max,
	"nc_fire:lump_coal"
)

------------------------------------------------------------------------
-- TORCH

addhint("craft a torch from staff and coal lump",
	"assemble torch",
	{"nc_woodwork:staff", "nc_fire:lump_coal"}
)

addhint("light a torch",
	"nc_torch:torch_lit",
	"assemble torch"
)

------------------------------------------------------------------------
-- WOODWORK

addhint("write on a surface with a charcoal lump",
	"charcoal writing",
	"nc_fire:lump_coal"
)

------------------------------------------------------------------------
-- WOODWORK

addhint("assemble a staff from sticks",
	"assemble staff",
	"nc_tree:stick"
)

addhint("assemble an adze out of sticks",
	"assemble wood adze",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

addhint("assemble a wooden ladder from sticks",
	"assemble wood ladder",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

addhint("assemble a wooden frame from staves",
	"assemble wood frame",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

addhint("split a tree trunk into planks",
	"split tree to planks",
	{true, "nc_woodwork:adze", "nc_woodwork:tool_hatchet"}
)

addhint("carve wooden tool heads from planks",
	"carve nc_woodwork:plank",
	"split tree to planks"
)

addhint("assemble a wooden tool",
	{true,
		"assemble wood mallet",
		"assemble wood spade",
		"assemble wood hatchet",
		"assemble wood pick",
	},
	"carve nc_woodwork:plank"
)

addhint("carve a wooden plank completely",
	"carve nc_woodwork:toolhead_pick",
	"carve nc_woodwork:plank"
)

addhint("bash a plank into sticks",
	"bash planks to sticks",
	{"nc_woodwork:plank", "toolcap:thumpy:3"}
)

addhint("assemble a wooden shelf from frames and planks",
	"assemble wood shelf",
	{"nc_woodwork:plank", "nc_woodwork:frame"}
)

------------------------------------------------------------------------
-- STONEWORK

addhint("break cobble into chips",
	"break cobble to chips",
	"nc_terrain:cobble_loose"
)

addhint("pack stone chips back into cobble",
	"repack chips to cobble",
	"nc_stonework:chip"
)

addhint("put a stone tip onto a wooden tool",
	{true,
		"assemble nc_stonework:tool_mallet",
		"assemble nc_stonework:tool_spade",
		"assemble nc_stonework:tool_hatchet",
		"assemble nc_stonework:tool_pick"
	},
	"nc_stonework:chip"
)

------------------------------------------------------------------------
-- CONCRETE

addhint("mix gravel into ash to make aggregate",
	"mix concrete",
	{"nc_terrain:gravel_loose", "nc_fire:ash"}
)

addhint("make wet aggregate",
	{true, "nc_concrete:wet_source", "nc_concrete:wet_flowing"},
	"mix concrete"
)

------------------------------------------------------------------------
-- LODE

addhint("find a lode stratum",
	"group:lodey"
)

addhint("find lode ore",
	"nc_lode:ore",
	"group:lodey"
)

addhint("dig up lode ore",
	"nc_lode:cobble_loose",
	"nc_lode:ore"
)

addhint("melt down lode metal from lode cobble",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	},
	"nc_lode:cobble_loose"
)

addhint("sinter glowing lode prills into a cube",
	"forge lode block",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	}
)

addhint("chop a glowing lode cube into prills",
	"break apart lode block",
	"forge lode block"
)

addhint("make an anvil by tempering a lode cube",
	"nc_lode:block_tempered",
	"forge lode block"
)

addhint("cold-forge annealed lode prills into a tool head",
	"anvil making lode toolhead_mallet",
	"nc_lode:block_tempered"
)

addhint("cold-forge lode down completely",
	"anvil making lode prills",
	"nc_lode:block_tempered"
)

addhint("temper a lode tool head",
	{true,
		"nc_lode:toolhead_mallet_tempered",
		"nc_lode:toolhead_spade_tempered",
		"nc_lode:toolhead_hatchet_tempered",
		"nc_lode:toolhead_pick_tempered"
	},
	"anvil making lode toolhead_mallet"
)

addhint("weld glowing lode pick and spade heads together",
	"assemble lode mattock head",
	"anvil making lode toolhead_pick"
)

addhint("hammer a lode prill into a bar",
	"anvil making lode bar",
	"nc_lode:block_tempered"
)

addhint("hammer a lode bar back to a prill",
	"anvil recycle lode bar",
	"anvil making lode bar"
)

addhint("hammer lode bars into a rod",
	"anvil making lode rod",
	"anvil making lode bar"
)

addhint("chop lode a rod back into bars",
	"recycle lode rod",
	"anvil making lode rod"
)

addhint("solder lode rods into crates",
	"assemble lode shelf",
	"anvil making lode rod"
)

addhint("chop a lode crate back apart",
	"break apart lode shelf",
	"assemble lode shelf"
)

------------------------------------------------------------------------
-- DOORS

addhint("chisel a hinge groove into a wooden plank",
	"drill door plank",
	{"anvil making lode rod", "split tree to planks"}
)

addhint("insert wooden pin into wooden door panel",
	"door pin plank",
	"drill door plank"
)

addhint("chisel a hinge groove into cobble",
	"drill door cobble",
	{"anvil making lode rod", "nc_terrain:cobble"}
)

addhint("insert metal rod into a cobble panel",
	"door pin cobble",
	"drill door cobble"
)

------------------------------------------------------------------------
-- LUX

addhint("find lux",
	"group:lux_emit"
)

addhint("dig up lux cobble",
	"group:lux_cobble",
	"group:lux_emit"
)

addhint("observe a lux reaction",
	"group:lux_hot",
	"group:lux_cobble"
)

addhint("observe lux criticality",
	"group:lux_cobble_max",
	"group:lux_hot"
)

addhint("lux-infuse a lode tool",
	"group:lux_tool",
	"group:lux_cobble_max"
)

------------------------------------------------------------------------
-- TOTE

addhint("assemble an annealed lode tote handle",
	"craft tote handle",
	{"nc_lode:block_annealed", "nc_woodwork:shelf"}
)

------------------------------------------------------------------------
-- OPTICS

addhint("melt sand into glass",
	"group:silica",
	"nc_terrain:sand_loose"
)

addhint("quench molten glass into chromatic glass",
	"nc_optics:glass_opaque",
	"group:silica"
)

addhint("mold molten glass into clear glass",
	"nc_optics:glass",
	"group:silica"
)

addhint("mold molten glass into float glass",
	"nc_optics:glass_float",
	{"nc_optics:glass", "group:lava"}
)

addhint("cool molten glass into crude glass",
	"nc_optics:glass_crude",
	"group:silica"
)

addhint("chip chromatic glass into prisms",
	"nc_optics:prism",
	"nc_optics:glass_opaque"
)

addhint("chop chromatic glass into lenses",
	"nc_optics:lens",
	"nc_optics:glass_opaque"
)

local opticactive = {true, "nc_optics:lens_on", "nc_optics:prism_on"}

addhint("activate a lens",
	opticactive,
	"nc_optics:lens"
)

addhint("produce light from a lens",
	"nc_optics:lens_glow",
	opticactive
)
