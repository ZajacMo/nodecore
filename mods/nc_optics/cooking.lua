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
		nodes = {
			{
				match = {groups = {sand = true}},
				replace = modname .. ":glass_hot_source"
			}
		}
	})

nodecore.register_cook_abm({
		nodenames = {"group:sand"},
		neighbors = {"group:flame"}
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
		nodes = {
			{
				match = src,
				replace = modname .. ":glass_crude"
			}
		}
	})

nodecore.register_cook_abm({nodenames = {src}})

nodecore.register_limited_abm({
		label = "Molten Glass Flowing",
		interval = 1,
		chance = 4,
		nodenames = {src},
		action = function(pos, node)
			local meta = minetest.get_meta(pos)
			local gen = meta:get_int("glassgen")
			if gen >= 32 and math_random(1, 2) == 1 then
				minetest.set_node(pos, {name = modname .. ":glass_crude"})
				nodecore.sound_play("nc_api_craft_hiss", {gain = 1, pos = pos})
				return nodecore.smokefx(pos, 0.2, 80)
			end
			local miny = pos.y
			local found = {}
			nodecore.scan_flood(pos, 5, function(p)
					local nn = minetest.get_node(p).name
					if nn == src then return end
					if nn ~= flow then return false end
					if p.y > miny then return end
					if p.y == miny then
						found[#found + 1] = p
						return
					end
					miny = p.y
					found = {p}
				end)
			if #found < 1 then return end
			local np = nodecore.pickrand(found)
			minetest.set_node(np, node)
			minetest.get_meta(np):set_int("glassgen", gen + 1)
			minetest.set_node(pos, {name = flow, param2 = 7})
		end
	})
