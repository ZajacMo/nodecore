-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "melt sand to glass",
		action = "cook",
		touchgroups = {
			coolant = 0,
			flame = 3
		},
		duration = 20,
		cookfx = true,
		indexkeys = {"group:sand"},
		nodes = {
			{
				match = {groups = {sand = true}},
				replace = modname .. ":glass_hot_source"
			}
		}
	})

nodecore.register_cook_abm({
		nodenames = {"group:sand"},
		neighbors = {"group:flame"},
		neighbors_invert = true
	})

local src = modname .. ":glass_hot_source"
local flow = modname .. ":glass_hot_flowing"

local function near(pos, crit)
	return #nodecore.find_nodes_around(pos, crit, {1, 1, 1}, {1, 0, 1}) > 0
end

nodecore.register_craft({
		label = "cool clear glass",
		action = "cook",
		priority = -1,
		duration = 120,
		cookfx = {smoke = true, hiss = true},
		check = function(pos)
			return not near(pos, {flow})
		end,
		indexkeys = {src},
		nodes = {
			{
				match = src,
				replace = modname .. ":glass"
			}
		}
	})

nodecore.register_craft({
		label = "cool float glass",
		action = "cook",
		duration = 120,
		cookfx = {smoke = true, hiss = true},
		check = function(pos)
			return not near(pos, {flow})
		end,
		indexkeys = {src},
		nodes = {
			{
				match = src,
				replace = modname .. ":glass_float"
			},
			{
				y = -1,
				match = {groups = {lava = true}}
			}
		}
	})

nodecore.register_craft({
		label = "quench opaque glass",
		action = "cook",
		cookfx = true,
		check = function(pos)
			return (not near(pos, {flow}))
			and nodecore.quenched(pos)
		end,
		indexkeys = {src},
		nodes = {
			{
				match = src,
				replace = modname .. ":glass_opaque"
			}
		}
	})
nodecore.register_craft({
		label = "quench crude glass",
		action = "cook",
		cookfx = true,
		check = function(pos)
			return near(pos, {flow})
			and nodecore.quenched(pos)
		end,
		indexkeys = {src},
		nodes = {
			{
				match = src,
				replace = modname .. ":glass_crude"
			}
		}
	})

nodecore.register_cook_abm({nodenames = {src}})

nodecore.register_fluidwandering(
	"glass",
	{src},
	2,
	function(pos, _, gen)
		if gen < 16 or math_random(1, 2) == 1 then return end
		minetest.set_node(pos, {name = modname .. ":glass_crude"})
		nodecore.sound_play("nc_api_craft_hiss", {gain = 1, pos = pos})
		nodecore.smokefx(pos, 0.2, 80)
		return true
	end
)
