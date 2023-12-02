-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "heat lode cobble",
		action = "cook",
		touchgroups = {flame = 3},
		neargroups = {coolant = 0},
		duration = 30,
		cookfx = true,
		indexkeys = {"group:lode_cobble"},
		nodes = {
			{
				match = {groups = {lode_cobble = true}},
				replace = modname .. ":cobble_hot"
			}
		},
	})

minetest.register_abm({
		label = "lode cobble drain",
		nodenames = {modname .. ":cobble_hot"},
		interval = 1,
		chance = 1,
		action = function(pos)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if not nodecore.air_pass(below) then return end
			nodecore.set_loud(pos, {name = "nc_terrain:cobble"})
			nodecore.witness(pos, "lode cobble drain")
			return nodecore.item_eject(below, modname
				.. ":prill_hot " .. (nodecore.exporand(1) + 1))
		end
	})

nodecore.register_craft({
		label = "lode ore cooling",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 0},
		duration = 120,
		priority = -1,
		cookfx = {smoke = true, hiss = true},
		indexkeys = {modname .. ":cobble_hot"},
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":ore"
			}
		}
	})

nodecore.register_craft({
		label = "lode ore quenching",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 0},
		cookfx = true,
		indexkeys = {modname .. ":cobble_hot"},
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":cobble"
			}
		}
	})

nodecore.register_cook_abm({nodenames = {"group:lode_cobble"}, neighbors = {"group:flame"}})
nodecore.register_cook_abm({nodenames = {modname .. ":cobble_hot"}})
