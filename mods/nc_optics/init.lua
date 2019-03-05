-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":lens", {
		description = "Lens",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-0.5, -0.5, -3/8, 0.25, -0.25, 1/8},
			{-0.25, 0.25, -3/8, 0.5, 0.5, 1/8},
			{-0.5, -0.25, -3/8, -0.25, 0.5, 1/8},
			{0.25, -0.5, -3/8, 0.5, 0.25, 1/8},
			{-0.25, -0.25, -1/8, 0.25, 0.25, 0.25}
		),
		tiles = {
			"nc_optics_glass.png",
			"nc_optics_glass.png",
			"nc_optics_glass.png",
			"nc_optics_glass.png",
			"nc_optics_glass.png^nc_optics_lens_out.png",
			"nc_optics_glass.png^nc_optics_lens_in.png",
		},
		groups = {cracky = 1},
		paramtype = "light",
		paramtype2 = "facedir"
	})

minetest.register_node(modname .. ":prism", {
		description = "Prism",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-3/8, -3/8, -0.5, -0.25, 3/8, -3/8},
			{3/8, -3/8, 0.25, 0.5, 3/8, 3/8},
			{-3/8, -0.5, -0.5, 0.5, -3/8, 3/8},
			{-3/8, 3/8, -0.5, 0.5, 0.5, 3/8},
			{-3/8, -3/8, -3/8, 3/8, 3/8, 3/8},
			{-0.25, -0.25, 3/8, 0.25, 0.25, 0.5},
			{-0.5, -0.25, -0.25, -3/8, 0.25, 0.25}
		),
		tiles = {
			"nc_optics_glass.png",
			"nc_optics_glass.png",
			"nc_optics_glass.png^nc_optics_prism_in.png",
			"nc_optics_glass.png^nc_optics_lens_out.png",
			"nc_optics_glass.png^nc_optics_lens_out.png",
			"nc_optics_glass.png^(nc_optics_prism_in.png^[transformFX)",
		},
		groups = {cracky = 1},
		paramtype = "light",
		paramtype2 = "facedir"
	})
