-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local txr_frame = modname .. "_glass_edges.png^(nc_tree_tree_side.png^[mask:"
.. modname .. "_tank_mask.png)"
local txr_pane = modname .. "_glass_glare.png"

minetest.register_node(modname .. ":shelf", {
		description = "Glass Tank",
		tiles = {
			txr_pane .. "^" .. txr_frame,
			txr_pane .. "^" .. txr_frame,
			txr_frame
		},
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			silica = 1,
			silica_clear = 1,
			cracky = 3,
			flammable = 20,
			fire_fuel = 2,
			visinv = 1,
			storebox = 1,
			totable = 1,
			scaling_time = 200
		},
		paramtype = "light",
		sunlight_propagates = true,
		air_pass = false,
		sounds = nodecore.sounds("nc_optics_glassy"),
		storebox_access = function(pt) return pt.above.y > pt.under.y end,
		on_ignite = function(pos)
			if minetest.get_node(pos).name == modname .. ":shelf" then
				return {modname .. ":glass_crude", nodecore.stack_get(pos)}
			end
			return modname .. ":glass_crude"
		end
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
