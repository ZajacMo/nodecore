-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc
    = ItemStack, core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local toolcaps = nc.toolcaps({
		uses = 0,
		crumbly = 1,
		snappy = 1,
		thumpy = 1,
		cuddly = 3
	})

core.register_item(":", {
		["type"] = "none",
		inventory_image = "[combine:1x1",
		tool_capabilities = toolcaps,
		node_placement_prediction = ""
	})

core.register_node(modname .. ":hand", {
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
		on_punch = core.remove_node,
		on_use = function() return ItemStack("") end,
		on_drop = function() return ItemStack("") end,
		on_place = function() return ItemStack("") end,
		mapcolor = {a = 0},
	})

nc.register_aism({
		label = "clean up misplaced player hands",
		interval = 1,
		chance = 1,
		itemnames = {modname .. ":hand"},
		action = function(_, data)
			if data.player and data.list == "hand" then return end
			return ItemStack("")
		end
	})
nc.register_lbm({
		name = modname .. ":cleanup",
		run_at_every_load = true,
		nodenames = {modname .. ":hand"},
		action = function(pos) return core.remove_node(pos) end
	})

nc.register_on_joinplayer(function(player)
		local inv = player:get_inventory()
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, modname .. ":hand")
	end)
