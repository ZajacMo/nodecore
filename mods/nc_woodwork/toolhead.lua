local modname = minetest.get_current_modname()

local function toolhead(name, from, sticks)
	local n = modname .. ":toolhead_" .. name:lower()
	local t = n:gsub(":", "_") .. ".png"
	minetest.register_node(n, {
			description = name .. " Tool Head",
			drawtype = "signlike",
			tiles = { t },
			inventory_image = t,
			paramtype = "light",
			paramtype2 = "wallmounted",
			propagates_sunlight = true,
			selection_box = {
				type = "fixed",
				fixed = { -7/16, -0.5, -7/16, 7/16, -7/16, 7/16 },
			},
			on_construct = function(pos, node)
				node = node or minetest.get_node(pos)
				if node.param2 ~= 1 then
					node.param2 = 1
					return minetest.set_node(pos, node)
				end
			end,
			groups = {
				crumbly = 3,
				falling_node = 1,
				falling_repose = 1,
			}
		})
	nodecore.extend_node(from, function(copy, orig)
			local oc = orig.can_pummel or function() end
			copy.can_pummel = function(pos, node, stats, ...)
				if (stats.pointed.above.y - stats.pointed.under.y) == 1
				and nodecore.wieldgroup(stats.puncher, "choppy") then
					return n
				end
				return oc(pos, node, stats)
			end
			local op = orig.on_pummel or function() end
			copy.on_pummel = function(pos, node, stats, ...)
				if stats.check ~= n or stats.duration < 5 then
					return op(pos, node, stats, ...)
				end
				minetest.set_node(pos, {name = n, param2 = 1})
				if sticks then
					minetest.item_drop(ItemStack("nc_tree:stick " .. sticks), nil,
						{x = pos.x, y = pos.y + 1, z = pos.z})
				end
				return true
			end
		end)
end

toolhead("Spade", modname .. ":plank", 1)
toolhead("Axe", modname .. ":toolhead_spade")
toolhead("Pick", modname .. ":toolhead_axe", 2)