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
		groups = {
			optic_check = 1,
			cracky = 1
		},
		on_construct = nodecore.optic_check,
		on_destruct = nodecore.optic_check,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rightclick = nodecore.node_spin,
		optic_check = function(pos, node, def)
			minetest.log("lens: " .. minetest.pos_to_string(pos))
		end
	})
