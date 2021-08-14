-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_hint("find lode ore",
	"nc_lode:ore",
	"toolcap:cracky:2"
)

nodecore.register_hint("dig up lode ore",
	"inv:nc_lode:cobble_loose",
	{"nc_lode:ore", "toolcap:cracky:2"}
)

nodecore.register_hint("melt down lode metal from lode cobble",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	},
	"inv:nc_lode:cobble_loose"
)

nodecore.register_hint("sinter glowing lode prills into a cube",
	"forge lode block",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	}
)

nodecore.register_hint("anneal a lode cube",
	"nc_lode:block_annealed",
	"forge lode block"
)

nodecore.register_hint("temper a lode cube to use as an anvil",
	"nc_lode:block_tempered",
	"forge lode block"
)

local any_lode_toolhead = {true,
	"annealed anvil making hot lode toolhead_mallet",
	"tempered anvil making hot lode toolhead_mallet",
	"tempered anvil making annealed lode toolhead_mallet"
}
local any_lode_anvil = {true,
	"nc_lode:block_annealed",
	"nc_lode:block_tempered"
}

nodecore.register_hint("forge lode prills into a tool head on an anvil",
	any_lode_toolhead,
	any_lode_anvil
)

nodecore.register_hint("cold-forge annealed lode on a tempered anvil",
	"tempered anvil making annealed lode toolhead_mallet",
	"nc_lode:block_tempered"
)

nodecore.register_hint("temper a lode tool head",
	{true,
		"nc_lode:toolhead_mallet_tempered",
		"nc_lode:toolhead_spade_tempered",
		"nc_lode:toolhead_hatchet_tempered",
		"nc_lode:toolhead_pick_tempered",
		"nc_lode:toolhead_mattock_tempered"
	},
	any_lode_toolhead
)

nodecore.register_hint("weld glowing lode pick and spade heads together",
	"assemble lode mattock head",
	{true,
		"annealed anvil making hot lode toolhead_pick",
		"tempered anvil making hot lode toolhead_pick",
		"tempered anvil making annealed lode toolhead_pick"
	}
)

nodecore.register_hint("hammer a lode prill into a bar",
	"anvil making lode bar",
	"nc_lode:block_tempered"
)

nodecore.register_hint("hammer lode bars into a rod",
	"anvil making lode rod",
	"anvil making lode bar"
)

nodecore.register_hint("solder lode rods into crates",
	"assemble lode shelf",
	"anvil making lode rod"
)

nodecore.register_hint("assemble a lode adze",
	"anvil making lode adze",
	"anvil making lode rod"
)

nodecore.register_hint("assemble a lode rake",
	"assemble lode rake",
	"anvil making lode adze"
)
