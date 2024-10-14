-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_craft({
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

core.register_abm({
		label = "lode cobble drain",
		nodenames = {modname .. ":cobble_hot"},
		interval = 1,
		chance = 1,
		action = function(pos)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if not nc.air_pass(below) then return end
			nc.set_loud(pos, {name = "nc_terrain:cobble"})
			nc.witness(pos, "lode cobble drain")
			return nc.item_eject(below, modname
				.. ":prill_hot " .. (nc.exporand(1) + 1))
		end
	})

nc.register_craft({
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

nc.register_craft({
		label = "lode ore quenching",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 1},
		cookfx = true,
		indexkeys = {modname .. ":cobble_hot"},
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":cobble"
			}
		}
	})

nc.register_cook_abm({nodenames = {"group:lode_cobble"}, neighbors = {"group:flame"}})
nc.register_cook_abm({nodenames = {modname .. ":cobble_hot"}})
