-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
= ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function toolhead(name, from, sticks)
	local n
	if name then
		local n = modname .. ":toolhead_" .. name:lower()
		local t = n:gsub(":", "_") .. ".png"
		minetest.register_craftitem(n, {
				description = "Plank " .. name .. " Head",
				inventory_image = t,
				stack_max = 1
			})
		--[[
		nodecore.register_craft({
				normal = {y = 1},
				nodes = {
					{match = n, replace = "air"},
					{y = -1, match = modname .. ":staff", replace = error("TOOLDEF")}
				}
			})
		--]]
	end
	nodecore.extend_pummel(from, 
		function(pos, node, stats)
			return nodecore.wieldgroup(stats.puncher, "choppy")
		end,
		function(pos, node, stats)
			if stats.duration < 5 then return end
			minetest.remove_node(pos)
			if n then minetest.item_drop(ItemStack(n), nil, pos) end
			if sticks then
				minetest.item_drop(ItemStack("nc_tree:stick " .. sticks),
					nil, {x = pos.x, y = pos.y + 1, z = pos.z})
			end
			return true
		end)
end

toolhead("Mallet", modname .. ":plank", 2)
toolhead("Spade", modname .. ":toolhead_mallet", 1)
toolhead("Axe", modname .. ":toolhead_spade", 1)
toolhead("Pick", modname .. ":toolhead_axe", 2)
toolhead(nil, modname.. ":toolhead_pick", 2)