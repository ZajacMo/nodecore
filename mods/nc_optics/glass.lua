-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":glass", {
		description = "Clear Glass",
		drawtype = "glasslike_framed_optional",
		tiles = {
			modname .. "_glass_glare.png^" .. modname .. "_glass_edges.png",
			modname .. "_glass_glare.png"
		},
		groups = {
			cracky = 3
		},
		sunlight_propagates = true,
		paramtype = "light"
	})

minetest.register_node(modname .. ":glass_opaque", {
		description = "Chromatic Glass",
		tiles = { modname .. "_glass_frost.png" },
		groups = {
			cracky = 3
		},
		paramtype = "light"
	})
