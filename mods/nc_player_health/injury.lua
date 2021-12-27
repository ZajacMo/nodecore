-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local injured = modname .. ":injured"
nodecore.register_virtual_item(injured, {
		description = "",
		inventory_image = "[combine:1x1",
		hotbar_type = "injury",
	})

nodecore.register_healthfx({
		item = injured,
		getqty = function(player)
			return 1 - nodecore.getphealth(player) / 8
		end,
		setqty = function(player, qty, ...)
			return nodecore.setphealth(player, (1 - qty) * 8, ...)
		end
	})
