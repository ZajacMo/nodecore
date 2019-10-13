-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hand = minetest.registered_items[""]
local injured = modname .. ":injured"
minetest.register_craftitem(injured, {
		description = "Injury",
		stack_max = 1,
		inventory_image = modname .. "_injured.png",
		wield_image = hand.wield_image,
		wield_scale = hand.wield_scale,
		on_drop = function(stack) return stack end,
		on_place = function(stack) return stack end,
		virtual_item = true
	})

nodecore.register_healthfx({
		item = injured,
		getqty = function(player, size)
			return math_floor(nodecore.getphealth(player)
				/ 20 * (size - 2) + 0.5) + 2
		end
	})
