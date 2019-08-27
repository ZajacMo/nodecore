-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local ashdirs = {
	{x = 1, y = -1, z = 0},
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 1},
	{x = 0, y = -1, z = -1}
}

nodecore.register_craft({
		label = "mix concrete (fail)",
		action = "pummel",
		priority = 2,
		toolgroups = {thumpy = 1},
		normal = {y = 1},
		nodes = {
			{
				match = "nc_terrain:gravel_loose"
			},
			{
				x = 1,
				y = -1,
				match = {buildable_to = true}
			},
			{
				y = -1,
				match = "nc_fire:ash",
				replace = "air"
			}
		},
		after = function(pos)
			local dirs = {}
			for _, d in pairs(ashdirs) do
				local p = vector.add(pos, d)
				if nodecore.buildable_to(p) then
					dirs[#dirs + 1] = {pos = p, qty = 0}
				end
			end
			for n = 1, 8 do
				local p = dirs[math_random(1, #dirs)]
				p.qty = p.qty + 1
			end
			for _, v in pairs(dirs) do
				if v.qty > 0 then
					nodecore.item_eject(v.pos, "nc_fire:lump_ash " .. v.qty)
				end
			end
		end
	})

nodecore.register_craft({
		label = "mix concrete",
		action = "pummel",
		priority = 1,
		toolgroups = {thumpy = 1},
		normal = {y = 1},
		nodes = {
			{
				match = "nc_terrain:gravel_loose",
				replace = "air"
			},
			{
				y = -1,
				match = "nc_fire:ash",
				replace = modname .. ":aggregate"
			}
		}
	})

local flow = modname .. ":wet_flowing"
local src = modname .. ":wet_source"

nodecore.register_limited_abm({
		label = "Aggregate Wettening",
		interval = 1,
		chance = 2,
		limited_max = 100,
		nodenames = {modname .. ":aggregate"},
		neighbors = {"group:water"},
		action = function(pos)
			minetest.set_node(pos, {name = src})
			nodecore.node_sound(pos, "place")
		end
	})

nodecore.register_limited_abm({
		label = "Aggregate Wandering",
		interval = 4,
		chance = 2,
		limited_max = 100,
		nodenames = {src},
		neighbors = {flow},
		action = function(pos, node)
			local meta = minetest.get_meta(pos)
			local gen = meta:get_int("agggen")
			if gen >= 8 and math_random(1, 2) == 1 then
				minetest.set_node(pos, {name = "nc_terrain:cobble"})
				return nodecore.node_sound(pos, "place")
			end
			local miny = pos.y
			local found = {}
			nodecore.scan_flood(pos, 2, function(p)
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
			nodecore.node_sound(pos, "dig")
			minetest.set_node(np, node)
			minetest.get_meta(np):set_int("agggen", gen + 1)
			minetest.set_node(pos, {name = flow, param2 = 7})
		end
	})

nodecore.register_craft({
		label = "aggregate curing",
		action = "cook",
		duration = 300,
		cookfx = {smoke = 0.05},
		check = function(pos)
			return not minetest.find_node_near(pos, 1, {flow, "group:water"})
		end,
		nodes = {
			{
				match = src,
				replace = "nc_terrain:stone"
			}
		}
	})

nodecore.register_cook_abm({nodenames = {src}})
