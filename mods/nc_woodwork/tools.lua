-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
= ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function toolhead(name, from, group, sticks, times)
	slow = slow or 1
	local n
	if name then
		n = modname .. ":toolhead_" .. name:lower()
		local t = n:gsub(":", "_") .. ".png"
		minetest.register_craftitem(n, {
				description = "Wooden " .. name .. " Head",
				inventory_image = t,
				stack_max = 1,
				groups = {
					flammable = 2,
					burn_away = 1
				}
			})
		local m = modname .. ":tool_" .. name:lower()
		local u = m:gsub(":", "_") .. ".png"
		minetest.register_tool(m, {
				description = "Wooden " .. name,
				inventory_image = u,
				groups = {
					flammable = 2,
					burn_away = 1

				},
				tool_capabilities = {
					groupcaps = {
						[group] = {
							times = times or {
								[1] = 4.00,
								[2] = 1.00,
								[3] = 0.50
							},
							uses = 20
						},
					},
				},
			})
		nodecore.register_craft({
				normal = {y = 1},
				nodes = {
					{match = n, replace = "air"},
					{y = -1, match = modname .. ":staff", replace = "air"},
				},
				items = {
					{y = -1, name = m},
				}
			})
	end
	nodecore.extend_pummel(from, 
		function(pos, node, stats)
			return nodecore.wieldgroup(stats.puncher, "choppy")
		end,
		function(pos, node, stats)
			if stats.duration < 5 then return end
			minetest.remove_node(pos)
			if n then nodecore.place_stack(pos, n) end
			if sticks then
				minetest.item_drop(ItemStack("nc_tree:stick " .. sticks),
					nil, {x = pos.x, y = pos.y + 1, z = pos.z})
				nodecore.wear_current_tool(stats.puncher, {choppy = 3})
			end
			return true
		end)
end

toolhead("Mallet", modname .. ":plank",
	"thumpy", 2, {
		[2] = 5.00,
		[3] = 2.00
	})
toolhead("Spade", modname .. ":toolhead_mallet",
	"crumbly", 1)
toolhead("Hatchet", modname .. ":toolhead_spade",
	"choppy", 1)
toolhead("Pick", modname .. ":toolhead_hatchet",
	"cracky", 2, {
		[2] = 20.00,
		[3] = 10.00
	})
toolhead(nil, modname.. ":toolhead_pick",
	nil, 2)
