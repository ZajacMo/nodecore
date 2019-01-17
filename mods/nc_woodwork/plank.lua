-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore
    = ItemStack, ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local plank = modname .. ":plank"
minetest.register_node(plank, {
		description = "Wooden Plank",
		tiles = { modname .. "_plank.png" },
		groups = {
			choppy = 3,
			flammable = 2,
			fire_fuel = 5
		}
	})

nodecore.extend_pummel("nc_tree:tree",
	function(pos, node, stats)
		return (stats.pointed.above.y - stats.pointed.under.y) == 1
		and nodecore.wieldgroup(stats.puncher, "choppy")
	end,
	function(pos, node, stats)
		if stats.duration < 5 then return end
		minetest.remove_node(pos)
		local defer = 0
		for _, v in ipairs({
				{x = pos.x + 1, y = pos.y, z = pos.z},
				{x = pos.x - 1, y = pos.y, z = pos.z},
				{x = pos.x, y = pos.y, z = pos.z + 1},
				{x = pos.x, y = pos.y, z = pos.z - 1}
				}) do
			if nodecore.buildable_to(v) then
				minetest.item_drop(ItemStack(plank), nil, v)
			else
				defer = defer + 1
			end
		end
		if defer > 0 then
			minetest.item_drop(ItemStack(plank .. " " .. defer), nil, pos)
		end
		nodecore.wear_current_tool(stats.puncher, {choppy = 3}, 2)
		return true
	end)
