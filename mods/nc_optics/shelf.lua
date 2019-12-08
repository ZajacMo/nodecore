-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local po = 0.5
local no = -0.5
local pi = 7/16
local ni = -7/16
minetest.register_node(modname .. ":shelf", {
		description = "Glass Tank",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{no, no, no, po, ni, po},
			{no, no, no, po, po, ni},
			{no, no, pi, po, po, po},
			{no, no, no, ni, po, po},
			{pi, no, no, po, po, po}
		),
		tiles = {modname .. "_glass_glare.png^" .. modname
			.. "_glass_edges.png^(nc_lode_annealed.png^[mask:"
			.. modname .. "_tank_mask.png)"},
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
