-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function toolhead(name, from, sticks)
	local n = modname .. ":toolhead_" .. name:lower()
	local t = n:gsub(":", "_") .. ".png"
	minetest.register_craftitem(n, {
			description = "Plank " .. name .. " Head",
			inventory_image = t
		})
	nodecore.extend_item(from, function(copy, orig)
			local oc = orig.can_pummel or function() end
			copy.can_pummel = function(pos, node, stats, ...)
				if nodecore.wieldgroup(stats.puncher, "choppy") then
					return n
				end
				return oc(pos, node, stats)
			end
			local op = orig.on_pummel or function() end
			copy.on_pummel = function(pos, node, stats, ...)
				if stats.check ~= n or stats.duration < 5 then
					return op(pos, node, stats, ...)
				end
				minetest.remove_node(pos)
				minetest.item_drop(ItemStack(n), nil, pos)
				if sticks then
					minetest.item_drop(ItemStack("nc_tree:stick " .. sticks),
						nil, {x = pos.x, y = pos.y + 1, z = pos.z})
				end
				return true
			end
		end)
end

toolhead("Spade", modname .. ":plank", 1)
toolhead("Axe", modname .. ":toolhead_spade")
toolhead("Pick", modname .. ":toolhead_axe", 2)
