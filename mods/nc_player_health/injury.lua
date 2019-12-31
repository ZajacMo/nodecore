-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hand = minetest.registered_items[""]
local injured = modname .. ":injured"
minetest.register_craftitem(injured, {
		description = "Injury",
		stack_max = 1,
		inventory_image = "[combine:1x1",
		hotbar_type = "injury",
		wield_image = hand.wield_image,
		wield_scale = hand.wield_scale,
		on_drop = function(stack) return stack end,
		on_place = function(stack) return stack end,
		virtual_item = true
	})

nodecore.register_healthfx({
		item = injured,
		getqty = function(player)
			return 1 - nodecore.getphealth(player) / 20
		end
	})
