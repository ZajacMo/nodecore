-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
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
				match = "nc_terrain:sand_loose",
				replace = modname .. ":glass_hot_source"
			}
		}
	})

nodecore.register_cook_abm({
		nodenames = {"nc_terrain:sand_loose"},
		neighbors = {"group:flame"}
	})

local src = modname .. ":glass_hot_source"
local flow = modname .. ":glass_hot_flowing"

nodecore.register_craft({
		label = "cool clear glass",
		action = "cook",
		priority = -1,
		duration = 120,
		cookfx = {smoke = true, hiss = true},
		check = function(pos)
			return #minetest.find_nodes_in_area(
				{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
				{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
				{flow}) < 1
		end,
		nodes = {
			{
				match = src,
				replace = modname .. ":glass"
			}
		}
	})
nodecore.register_craft({
		label = "quench opaque glass",
		action = "cook",
		cookfx = true,
		check = function(pos)
			return #minetest.find_nodes_in_area(
				{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
				{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
				{flow}) < 1
			and #minetest.find_nodes_in_area(
				{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
				{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
				{"group:coolant"}) > 0
		end,
		nodes = {
			{
				match = src,
				replace = modname .. ":glass_opaque"
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
			return minetest.set_node(pos, {name = flow, param2 = 7})
		end})
