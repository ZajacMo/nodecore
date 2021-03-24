-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local toolcaps = nodecore.toolcaps({
		uses = 0,
		crumbly = 1,
		snappy = 1,
		thumpy = 1
	})

minetest.register_item(":", {
		["type"] = "none",
		inventory_image = "[combine:1x1",
		tool_capabilities = toolcaps,
		node_placement_prediction = ""
	})

local scale = 2
minetest.register_node(modname .. ":hand", {
		description = "",
		drawtype = "mesh",
		mesh = modname .. ".obj",
		tiles = {"nc_player_model_base.png"},
		use_texture_alpha = "clip",
		wield_scale = {x = scale, y = scale, z = scale},
		virtual_item = true,
		stack_max = 1,
		node_placement_prediction = "",
		on_punch = minetest.remove_node
	})

nodecore.register_on_joinplayer("join set hand", function(player)
		local inv = player:get_inventory()
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, modname .. ":hand")
	end)
