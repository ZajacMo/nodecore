-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local addhint = nodecore.addhint

------------------------------------------------------------------------
-- SCALING

addhint("scaled a sheer wall", "scale sheer walls")
addhint("scaled a sheer overhang", "scale sheer ceilings")

------------------------------------------------------------------------
-- TERRAIN

addhint("dug up dirt",
	"nc_terrain:dirt_loose"
)

addhint("dug up gravel",
	"nc_terrain:gravel_loose",
	"toolcap:crumbly:2"
)

addhint("dug up sand",
	"nc_terrain:sand_loose"
)

addhint("dug up stone",
	"nc_terrain:cobble_loose",
	"toolcap:cracky:2"
)

addhint("found deep stone strata",
	"group:hard_stone",
	"nc_terrain:cobble_loose"
)

addhint("found molten rock",
	"group:lava",
	"nc_terrain:cobble_loose"
)

------------------------------------------------------------------------
-- SPONGE

addhint("found sponges",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("harvested a sponge",
	"nc_sponge:sponge_wet",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("dried out a sponge",
	"nc_sponge:sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

addhint("squeezed out a sponge",
	"squeeze sponge",
	{true,
		"nc_sponge:sponge",
		"nc_sponge:sponge_wet",
		"nc_sponge:sponge_living"
	}
)

------------------------------------------------------------------------
-- TREE

addhint("found dry leaves",
	"nc_tree:leaves_loose"
)

addhint("found eggcorns",
	"nc_tree:eggcorn"
)

addhint("planted an eggcorn",
	"eggcorn planting",
	{"nc_tree:eggcorn", "nc_terrain:dirt_loose"}
)

addhint("found sticks",
	"nc_tree:stick"
)

addhint("cut down a tree",
	"dig:nc_tree:tree",
	"toolcap:choppy:2"
)

addhint("dug up a tree stump",
	"dig:nc_tree:root",
	"toolcap:choppy:4"
)

------------------------------------------------------------------------
-- FIRE

addhint("made fire by rubbing sticks together",
	"stick fire starting",
	"nc_tree:stick"
)

addhint("found ash",
	"nc_fire:ash",
	"stick fire starting"
)

addhint("found charcoal",
	"group:charcoal",
	"stick fire starting"
)

addhint("chopped up charcoal",
	"nc_fire:lump_coal",
	"group:charcoal"
)

addhint("packed high-quality charcoal",
	"nc_fire:coal" .. nodecore.fire_max,
	"nc_fire:lump_coal"
)

------------------------------------------------------------------------
-- WOODWORK

addhint("assembled a staff from sticks",
	"assemble staff",
	"nc_tree:stick"
)

addhint("assembled an adze out of sticks",
	"assemble wood adze",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

addhint("assembled a wooden ladder",
	"assemble wood ladder",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

addhint("assembled a wooden frame",
	"assemble wood frame",
	{true, "nc_tree:stick", "nc_woodwork:staff"}
)

addhint("split a tree trunk into planks",
	"split tree to planks",
	{true, "nc_woodwork:adze", "nc_woodwork:tool_hatchet"}
)

addhint("carved wooden tool heads from planks",
	"carve nc_woodwork:plank",
	"split tree to planks"
)

addhint("assembled a wooden tool",
	{true,
		"assemble wood mallet",
		"assemble wood spade",
		"assemble wood hatchet",
		"assemble wood pick",
	},
	"carve nc_woodwork:plank"
)

addhint("carved a wooden plank completely",
	"carve nc_woodwork:toolhead_pick",
	"carve nc_woodwork:plank"
)

addhint("bashed a plank into sticks",
	"bash planks to sticks",
	{"nc_woodwork:plank", "toolcap:thumpy:3"}
)

addhint("assembled a wooden shelf",
	"assemble wood shelf",
	{"nc_woodwork:plank", "nc_woodwork:frame"}
)

------------------------------------------------------------------------
-- STONEWORK

addhint("broken cobble into chips",
	"break cobble to chips",
	"nc_terrain:cobble_loose"
)

addhint("packed stone chips back into cobble",
	"repack chips to cobble",
	"nc_stonework:chip"
)

addhint("put a stone tip onto a tool",
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

addhint("blended gravel into ash to make aggregate",
	"mix concrete",
	{"nc_terrain:gravel_loose", "nc_fire:ash"}
)

addhint("made wet aggregate",
	{true, "nc_concrete:wet_source", "nc_concrete:wet_flowing"},
	"mix concrete"
)

------------------------------------------------------------------------
-- LODE

addhint("found a lode stratum",
	"group:lodey"
)

addhint("found lode ore",
	"nc_lode:ore",
	"group:lodey"
)

addhint("dug up lode ore",
	"nc_lode:cobble_loose",
	"nc_lode:ore"
)

local lodeprill = {true,
	"nc_lode:prill_hot",
	"nc_lode:prill_annealed",
	"nc_lode:prill_tempered"
}

addhint("melted down lode metal",
	lodeprill,
	"nc_lode:cobble_loose"
)

addhint("sintered glowing lode into a cube",
	"forge lode block",
	"nc_lode:prill_hot"
)

addhint("chopped a lode cube into prills",
	"break apart lode block",
	"forge lode block"
)

addhint("tempered a lode anvil",
	"nc_lode:block_tempered",
	"forge lode block"
)

addhint("cold-forged an annealed lode tool head",
	"anvil making lode toolhead_mallet",
	"nc_lode:block_tempered"
)

addhint("cold-forged lode down completely",
	"anvil making lode prills",
	"nc_lode:block_tempered"
)

addhint("tempered a lode tool head",
	{true,
		"nc_lode:toolhead_mallet_tempered",
		"nc_lode:toolhead_spade_tempered",
		"nc_lode:toolhead_hatchet_tempered",
		"nc_lode:toolhead_pick_tempered"
	},
	"anvil making lode toolhead_mallet"
)

addhint("welded a lode pick and spade together",
	"assemble lode mattock head",
	"anvil making lode toolhead_pick"
)

------------------------------------------------------------------------
-- LUX

addhint("found lux stone",
	"group:lux_emit"
)

addhint("collected lux cobble",
	"group:lux_cobble",
	"group:lux_emit"
)

addhint("observed a lux reaction",
	"group:lux_hot",
	"group:lux_cobble"
)

addhint("observed lux criticality",
	"group:lux_cobble_max",
	"group:lux_hot"
)

addhint("lux-infused a lode tool",
	"group:lux_tool",
	"group:lux_cobble_max"
)

------------------------------------------------------------------------
-- TOTE

addhint("assembled an annealed lode tote handle",
	"craft tote handle",
	{"nc_lode:block_annealed", "nc_woodwork:shelf"}
)

------------------------------------------------------------------------
-- OPTICS

addhint("melted sand into glass",
	"group:silica",
	"nc_terrain:sand_loose"
)

addhint("quenched molten glass into chromatic glass",
	"nc_optics:glass_opaque",
	"group:silica"
)

addhint("molded molten glass into clear glass",
	"nc_optics:glass",
	"group:silica"
)

addhint("molded molten glass into float glass",
	"nc_optics:glass_float",
	"nc_optics:glass"
)

addhint("cooled molten glass into crude glass",
	"nc_optics:glass_crude",
	"group:silica"
)

addhint("chipped chromatic glass into prisms",
	"nc_optics:prism",
	"nc_optics:glass_opaque"
)

addhint("chopped chromatic glass into lenses",
	"nc_optics:lens",
	"nc_optics:glass_opaque"
)

local opticactive = {true, "nc_optics:lens_on", "nc_optics:prism_on"}

addhint("activated a lens",
	opticactive,
	"nc_optics:lens"
)

addhint("produced light from a lens",
	"nc_optics:lens_glow",
	opticactive
)
