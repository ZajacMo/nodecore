-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local plank = modname .. ":plank"
minetest.register_node(plank, {
		description = "Wooden Plank",
		tiles = { modname .. "_plank.png" },
		groups = {
			choppy = 1,
			flammable = 2,
			fire_fuel = 5
		}
	})

-- PUMDEF
nodecore.extend_pummel("nc_tree:tree",
	function(pos, node, stats)
		return (stats.pointed.above.y - stats.pointed.under.y) == 1
		and nodecore.toolspeed(stats.puncher:get_wielded_item(),
			{choppy = 1})
	end,
	function(pos, node, stats)
		if stats.duration < stats.check + 2 then return end
		minetest.remove_node(pos)
		nodecore.item_eject(pos, plank, 5, 4)
		nodecore.wear_current_tool(stats.puncher, {choppy = 3}, 2)
		return true
	end)
