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
			choppy = 3
		}
	})

local upright = {[0]=true,[1]=true,[2]=true,[3]=true,[20]=true,[21]=true,[22]=true,[23]=true}
for _, name in ipairs({"nc_tree:tree", "nc_tree:log"}) do
	nodecore.extend_node(name, function(copy, orig)
			local op = orig.on_pummel or function() end
			copy.on_pummel = function(pos, node, stats, ...)
				if not upright[node.param2]
				or (stats.pointed.above.y - stats.pointed.under.y) ~= 1
				or stats.duration < 5 then
					return op(pos, node, stats, ...)
				end
				local wielded = stats.puncher:get_wielded_item()
				local caps = wielded:get_tool_capabilities()
				local choppy = caps and caps.groupcaps and caps.groupcaps.choppy
				if not choppy then
					return op(pos, node, stats, ...)
				end
				minetest.remove_node(pos)
				local defer = 0
				for _, v in ipairs({
						{x = pos.x + 1, y = pos.y, z = pos.z},
						{x = pos.x - 1, y = pos.y, z = pos.z},
						{x = pos.x, y = pos.y, z = pos.z + 1},
						{x = pos.x, y = pos.y, z = pos.z - 1}
						}) do
					if minetest.registered_nodes[minetest.get_node(v)
					.name].buildable_to then
						minetest.item_drop(ItemStack(plank), nil, v)
					else
						defer = defer + 1
					end
				end
				if defer > 0 then
					minetest.item_drop(ItemStack(plank .. " " .. defer), nil, pos)
				end
			end
		end)
end
