-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local injured = modname .. ":injured"
nc.register_virtual_item(injured, {
		description = "",
		inventory_image = "[combine:1x1",
		hotbar_type = "injury",
	})

nc.register_healthfx({
		item = injured,
		getqty = function(player)
			return 1 - nc.getphealth(player) / 8
		end,
		setqty = function(player, qty, ...)
			return nc.setphealth(player, (1 - qty) * 8, ...)
		end
	})
