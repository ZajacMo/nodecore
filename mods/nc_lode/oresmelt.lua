-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "heat lode cobble",
		action = "cook",
		touchgroups = {flame = 3},
		duration = 30,
		cookfx = true,
		indexkeys = {"group:lode_cobble"},
		nodes = {
			{
				match = {groups = {lode_cobble = true}},
				replace = modname .. ":cobble_hot"
			}
		}
	})

nodecore.register_limited_abm({
		label = "lode cobble drain",
		nodenames = {modname .. ":cobble_hot"},
		interval = 1,
		chance = 1,
		action = function(pos)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if nodecore.walkable(below) then return end
			nodecore.set_loud(pos, {name = "nc_terrain:cobble"})
			return nodecore.item_eject(below, modname
				.. ":prill_hot " .. (nodecore.exporand(1) + 1))
		end
	})

nodecore.register_craft({
		label = "lode ore cooling",
		action = "cook",
		touchgroups = {flame = 0},
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
		cookfx = true,
		check = function(pos)
			return nodecore.quenched(pos)
		end,
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
