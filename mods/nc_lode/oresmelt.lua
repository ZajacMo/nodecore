-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_exp, math_floor, math_log, math_random
    = math.exp, math.floor, math.log, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local logadj = math_log(2)
local function exporand()
	local r = 0
	while r == 0 do r = math_random() end
	return math_floor(math_exp(-math_log(r) * logadj))
end

nodecore.register_craft({
		label = "heat lode cobble",
		action = "cook",
		touchgroups = {flame = 3},
		duration = 30,
		cookfx = true,
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
			if nodecore.match(below, {walkable = true}) then return end
			minetest.set_node(pos, {name = "nc_terrain:cobble"})
			nodecore.node_sound(pos, "place")
			return nodecore.item_eject(below, modname
				.. ":prill_hot " .. exporand())
		end
	})

nodecore.register_craft({
		label = "lode ore cooling",
		action = "cook",
		touchgroups = {flame = 0},
		duration = 30,
		priority = -1,
		cookfx = {smoke = true, hiss = true},
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":cobble"
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
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":cobble"
			}
		}
	})

nodecore.register_cook_abm({nodenames = {"group:lode_cobble"}, neighbors = {"group:flame"}})
nodecore.register_cook_abm({nodenames = {modname .. ":cobble_hot"}})
