-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local addhint = nodecore.addhint

addhint("dug up dirt",
	"nc_terrain:dirt_loose")

addhint("dug up sand",
	"nc_terrain:sand_loose")

addhint("found dry leaves",
	"nc_tree:leaves_loose")

addhint("found eggcorns",
	"nc_tree:eggcorn")

addhint("planted an eggcorn",
	"nc_tree:eggcorn_planted",
	"nc_tree:eggcorn")

addhint("found sticks",
	"nc_tree:stick")

addhint("crafted a staff from sticks",
	"nc_woodwork:staff",
	"nc_tree:stick")

addhint("crafted an adze out of sticks",
	"nc_woodwork:adze",
	{true, "nc_tree:stick", "nc_woodwork:staff"})

addhint("constructed a wooden ladder",
	"nc_woodwork:ladder",
	{true, "nc_tree:stick", "nc_woodwork:staff"})

addhint("constructed a wooden frame",
	"nc_woodwork:frame",
	{true, "nc_tree:stick", "nc_woodwork:staff"})

addhint("split a tree trunk into planks",
	"nc_woodwork:plank",
	{true, "nc_woodwork:adze", "nc_woodwork:tool_hatchet"})

local woodhead = addhint("carved wooden tool heads from planks",
	{true,
		"nc_woodwork:toolhead_mallet",
		"nc_woodwork:toolhead_spade",
		"nc_woodwork:toolhead_hatchet",
		"nc_woodwork:toolhead_pick",
	},
	"nc_woodwork:plank")

addhint("assembled a wooden tool",
	{true,
		"nc_woodwork:tool_mallet",
		"nc_woodwork:tool_spade",
		"nc_woodwork:tool_hatchet",
		"nc_woodwork:tool_pick",
	},
	woodhead.goal)

addhint("made each kinds of wooden tool head",
	{
		"nc_woodwork:toolhead_mallet",
		"nc_woodwork:toolhead_spade",
		"nc_woodwork:toolhead_hatchet",
		"nc_woodwork:toolhead_pick",
	},
	woodhead.goal)

addhint("cut down a tree",
	"nc_tree:tree",
	"nc_woodwork:tool_hatchet")

addhint("dug up stone",
	"nc_terrain:cobble_loose",
	"nc_woodwork:tool_pick")

addhint("broken cobble into chips",
	"nc_stonework:chip",
	"nc_terrain:cobble_loose")

addhint("put a stone tip onto a tool",
	{true,
		"nc_stonework:tool_mallet",
		"nc_stonework:tool_spade",
		"nc_stonework:tool_hatchet",
		"nc_stonework:tool_pick"
	},
	"nc_stonework:chip")

local embers = addhint("made fire by rubbing sticks together",
	{true,
		"nc_fire:ember1",
		"nc_fire:ember2",
		"nc_fire:ember3",
		"nc_fire:ember4",
		"nc_fire:ember5",
		"nc_fire:ember6",
		"nc_fire:ash",
	},
	"nc_tree:stick")

addhint("set fire to long-lasting fuels",
	{true,
		"nc_fire:ember5",
		"nc_fire:ember6",
		"nc_fire:ash",
	},
	embers.goal)

addhint("found ash",
	"nc_fire:ash",
	embers.goal)

local lodefind = addhint("found a lode deposit",
	{true,
		"nc_lode:stone",
		"nc_lode:ore"
	})

local lodeore = addhint("found lode ore",
	"nc_lode:ore",
	lodefind.goal)

addhint("dug out lode ore",
	"nc_lode:cobble_loose",
	lodeore.goal)

local lodesmelt = addhint("melted down lode metal",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	},
	"nc_lode:cobble_loose")

local anvil = addhint("constructed a lode anvil",
	"nc_lode:block_tempered",
	lodesmelt.goal)

local annealhead = addhint("cold-forged a lode tool head",
	{true,
		"nc_lode:toolhead_mallet_annealed",
		"nc_lode:toolhead_spade_annealed",
		"nc_lode:toolhead_hatchet_annealed",
		"nc_lode:toolhead_pick_annealed"
	},
	anvil.goal)

addhint("tempered a lode tool head",
	{true,
		"nc_lode:toolhead_mallet_tempered",
		"nc_lode:toolhead_spade_tempered",
		"nc_lode:toolhead_hatchet_tempered",
		"nc_lode:toolhead_pick_tempered"
	},
	annealhead.goal)

addhint("constructed a shelf",
	"nc_woodwork:shelf",
	{ "nc_woodwork:frame", "nc_woodwork:plank" })

addhint("found sponges",
	{ "nc_sponge:sponge", "nc_sponge:sponge_wet", "nc_sponge:sponge_living" })
