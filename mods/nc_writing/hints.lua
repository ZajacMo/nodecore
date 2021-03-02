-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_hint("write on a surface with a charcoal lump",
	"charcoal writing",
	"nc_fire:lump_coal"
)

nodecore.register_hint("rotate a charcoal glyph",
	"charcoal writing rotate",
	"charcoal writing"
)

local placedall = {}
for i = 1, #nodecore.writing_glyphs do
	placedall[#placedall + 1] = "place:" .. modname .. ":glyph" .. i
end

nodecore.register_hint("cycle through all charcoal glyphs",
	placedall,
	"charcoal writing"
)
