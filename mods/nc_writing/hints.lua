-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs
    = core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_hint("write on a surface with a charcoal lump",
	"charcoal writing",
	"nc_fire:lump_coal"
)

nc.register_hint("rotate a charcoal glyph",
	"charcoal writing rotate",
	"charcoal writing"
)

local placedall = {}
for i = 1, #nc.writing_glyphs do
	placedall[#placedall + 1] = "place:" .. modname .. ":glyph" .. i
end

nc.register_hint("cycle through all charcoal glyphs",
	placedall,
	"charcoal writing"
)

for _, v in pairs({"sand", "gravel", "dirt"}) do
	nc.register_hint("rake " .. v,
		"rake " .. v,
		{"group:rakey", "nc_terrain:" .. v}
	)
end
nc.register_hint("rake humus",
	"rake humus",
	{"group:rakey", "nc_tree:humus"}
)

nc.register_hint("leach raked humus to dirt",
	"leach group:humus_raked",
	"group:humus_raked"
)
nc.register_hint("leach raked dirt to sand",
	"leach group:dirt_raked",
	"group:dirt_raked"
)
