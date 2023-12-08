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
	"lode cobble drain",
	"inv:nc_lode:cobble_loose"
)

nodecore.register_hint("sinter glowing lode prills into a cube",
	"forge lode block",
	"nc_lode:prill_hot"
)

nodecore.register_hint("anneal a lode cube",
	"metallurgize nc_lode:block_annealed",
	"forge lode block"
)

nodecore.register_hint("temper a lode cube",
	"metallurgize nc_lode:block_tempered",
	"forge lode block"
)

nodecore.register_hint("work glowing lode on a stone anvil",
	"anvil:hot/stone",
	"nc_lode:prill_hot"
)

nodecore.register_hint("work glowing lode on a lode anvil",
	{true,
		"anvil:hot/annealed",
		"anvil:hot/tempered",
	},
	"nc_lode:block_annealed"
)

nodecore.register_hint("work annealed lode on a tempered lode anvil",
	"anvil:cold/tempered",
	"nc_lode:block_tempered"
)

nodecore.register_hint("forge lode prills into a tool head",
	"forge lode toolhead_mallet",
	{true,
		"nc_lode:prill_hot",
		"nc_lode:prill_annealed",
		"nc_lode:prill_tempered"
	}
)

nodecore.register_hint("temper a lode tool head",
	{true,
		"metallurgize nc_lode:toolhead_mallet_tempered",
		"metallurgize nc_lode:toolhead_spade_tempered",
		"metallurgize nc_lode:toolhead_hatchet_tempered",
		"metallurgize nc_lode:toolhead_pick_tempered",
		"metallurgize nc_lode:toolhead_mattock_tempered"
	},
	"forge lode toolhead_mallet"
)

nodecore.register_hint("weld glowing lode pick and spade heads together",
	"assemble lode mattock head",
	"forge lode toolhead_pick"
)

nodecore.register_hint("forge a lode prill into a bar",
	"anvil making lode bar",
	"lode anvil"
)

nodecore.register_hint("forge lode bars into a rod",
	"anvil making lode rod",
	"anvil making lode bar"
)

nodecore.register_hint("forge a lode rod and bar into a ladder",
	"anvil making lode ladder",
	"anvil making lode rod"
)

nodecore.register_hint("forge lode rods into a frame",
	"anvil making lode frame",
	"anvil making lode rod"
)

nodecore.register_hint("forge an annealed lode frame into a form",
	"lode frame_annealed to form",
	"anvil making lode frame"
)

nodecore.register_hint("assemble a lode crate from form and bar",
	"assemble lode shelf",
	"lode frame_annealed to form"
)

nodecore.register_hint("assemble a lode adze",
	"anvil making lode adze",
	"anvil making lode rod"
)

nodecore.register_hint("assemble a lode rake",
	"assemble lode rake",
	"anvil making lode adze"
).hide = true

nodecore.register_hint("assemble lode tongs",
	"anvil making lode tongs",
	"anvil making lode adze"
)
