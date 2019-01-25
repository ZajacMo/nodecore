-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
= minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_craftitem(modname .. ":chip", {
		description = "Stone Chip",
		inventory_image = modname .. "_stone.png",
		pummel_stack = 8,
		pummeldefs = {
			{
				check = function(pos, node, stats)
					return nodecore.toolspeed(
						stats.puncher:get_wielded_item(),
						{thumpy = 2})
				end,
				resolve = function(pos, node, stats)
					if stats.duration < stats.check + 2 then return end
					nodecore.wear_current_tool(stats.puncher, {thumpy = 1})
					minetest.set_node(pos, {name = "nc_terrain:cobble_loose"})
					return true
				end
			}
		}
	})

nodecore.extend_pummel("nc_terrain:cobble_loose",
	function(pos, node, stats)
		return nodecore.toolspeed(
			stats.puncher:get_wielded_item(),
			{cracky = 1})
	end,
	function(pos, node, stats)
		if stats.duration < stats.check + 2 then return end
		nodecore.wear_current_tool(stats.puncher, {cracky = 1})
		minetest.remove_node(pos)
		nodecore.item_eject(pos, modname .. ":chip", 5, 8)
	end)
