-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local txr_frame = modname .. "_glass_edges.png^(nc_tree_tree_side.png^[mask:"
.. modname .. "_tank_mask.png)"
local txr_pane = modname .. "_glass_glare.png"

local txr_main = {name = txr_pane .. "^" .. txr_frame, backface_culling = true}
local txr_top = {name = txr_frame, backface_culling = true}

minetest.register_node(modname .. ":shelf", {
		description = "Glass Tank",
		drawtype = "mesh",
		mesh = "nc_api_shelf.obj",
		tiles = {txr_main, txr_main, txr_top},
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 3,
			visinv = 1,
			shelf = 1,
			totable = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_optics_glassy"),
		shelf_access = function(pt) return pt.above.y > pt.under.y end
	})

nodecore.register_craft({
		label = "assemble glass tank",
		norotate = true,
		nodes = {
			{match = "nc_woodwork:frame", replace = "air"},
			{x = -1, z = -1, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = 1, z = -1, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = -1, z = 1, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = 1, z = 1, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = 0, z = -1, match = "nc_woodwork:staff", replace = "air"},
			{x = 0, z = 1, match = "nc_woodwork:staff", replace = "air"},
			{x = -1, z = 0, match = "nc_woodwork:staff", replace = "air"},
			{x = 1, z = 0, match = "nc_woodwork:staff", replace = "air"},
		}
	})

nodecore.register_craft({
		label = "assemble glass tank",
		norotate = true,
		nodes = {
			{match = "nc_woodwork:frame", replace = "air"},
			{x = 0, z = -1, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = 0, z = 1, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = -1, z = 0, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = 1, z = 0, match = modname .. ":glass", replace = modname .. ":shelf"},
			{x = -1, z = -1, match = "nc_woodwork:staff", replace = "air"},
			{x = 1, z = 1, match = "nc_woodwork:staff", replace = "air"},
			{x = -1, z = 1, match = "nc_woodwork:staff", replace = "air"},
			{x = 1, z = -1, match = "nc_woodwork:staff", replace = "air"},
		}
	})
