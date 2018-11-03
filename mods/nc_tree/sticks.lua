-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":stick", {
		description = "Stick",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			snappy = 2,
			falling_repose = 1
		},
		on_rightclick = function(pos, node, clicker, stack, pointed)
			if pointed.above.y <= pointed.under.y then return end
			if stack:is_empty() or stack:get_name() ~= modname .. ":stick" then return end
			minetest.set_node(pointed.under, {name = modname .. ":staff"})
			stack:set_count(stack:get_count() - 1)
			return stack
		end
	})

nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {
			name = modname .. ":stick",
			prob = 0.2 * (node.param2 * node.param2)}
	end)

minetest.register_node(modname .. ":staff", {
		description = "Staff",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			snappy = 2,
			falling_repose = 2
		},
		on_rightclick = function(pos, node, clicker, stack, pointed, ...)
			if pointed.above.y <= pointed.under.y then return end
			if stack:is_empty() then return end
			local function become(name)
				minetest.remove_node(pos)
				minetest.item_drop(ItemStack(name), nil, pointed.under)
				if stack then stack:set_count(stack:get_count() - 1) end
				return stack
			end
			if stack:get_name() == modname .. ":stick" then
				return become(modname .. ":adze")
			end
		end	
	})

minetest.register_tool(modname .. ":adze", {
		description = "Adze",
		inventory_image = modname .. "_adze.png",
		tool_capabilities = {
			full_punch_interval = 1.2,
			groupcaps = {
				choppy = {times={[3]=1.60}, uses=20, maxlevel=1},
			}
		},
	})
