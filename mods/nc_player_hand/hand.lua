-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local toolcaps = nodecore.toolcaps({
		uses = 0,
		crumbly = 1,
		snappy = 1,
		thumpy = 1,
		cuddly = 3
	})

minetest.register_item(":", {
		["type"] = "none",
		inventory_image = "[combine:1x1",
		tool_capabilities = toolcaps,
		node_placement_prediction = ""
	})

minetest.register_node(modname .. ":hand", {
		description = "",
		drawtype = "mesh",
		mesh = modname .. ".obj",
		tiles = {"nc_player_model_base.png"},
		use_texture_alpha = "clip",
		wield_scale = {x = 2, y = 2, z = 2},
		virtual_item = true,
		stack_max = 1,
		node_placement_prediction = "",
		paramtype = "light",
		on_punch = minetest.remove_node,
		on_use = function() return ItemStack("") end,
		on_drop = function() return ItemStack("") end,
		on_place = function() return ItemStack("") end,
		mapcolor = {a = 0},
	})

nodecore.register_aism({
		label = "clean up misplaced player hands",
		interval = 1,
		chance = 1,
		itemnames = {modname .. ":hand"},
		action = function(_, data)
			if data.player and data.list == "hand" then return end
			return ItemStack("")
		end
	})
nodecore.register_lbm({
		name = modname .. ":cleanup",
		run_at_every_load = true,
		nodenames = {modname .. ":hand"},
		action = function(pos) return minetest.remove_node(pos) end
	})

nodecore.register_on_joinplayer(function(player)
		local inv = player:get_inventory()
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, modname .. ":hand")
	end)
