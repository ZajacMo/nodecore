-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function toolhead(name, group)
	local n = name:lower()

	nodecore.register_lode("toolhead_" .. n, {
			type = "craft",
			description = "## Lode " .. name .. " Head",
			inventory_image = modname .. "_#.png^[mask:" ..
			modname .. "_toolhead_" .. n .. ".png",
			stack_max = 1
		})

	nodecore.register_lode("tool_" .. n, {
			type = "tool",
			description = "## Lode " .. name,
			inventory_image = modname .. "_tool_handle.png^(" ..
			modname .. "_#.png^[mask:" ..
			modname .. "_tool_" .. n .. ".png)",
			stack_max = 1,
			tool_capabilities = nodecore.toolcaps({
					[group] = 4
				}),
			bytemper = function(t, d)
				if t == "Tempered" then
					d.tool_capabilities = nodecore.toolcaps({
							[group] = 5
						})
				end
			end,
			metal_alt_hot = modname .. ":toolhead_" .. n .. "_hot",
			tool_wears_to = modname .. ":prill_# 3",

		})

	for _, t in pairs({"annealed", "tempered"}) do
		nodecore.register_craft({
				label = "assemble lode " .. n,
				normal = {y = 1},
				nodes = {
					{match = modname .. ":toolhead_" .. n .. "_" .. t,
						replace = "air"},
					{y = -1, match = "nc_woodwork:staff", replace = "air"},
				},
				items = {
					{y = -1, name = modname .. ":tool_" .. n .. "_" .. t},
				}
			})
	end
end

toolhead("Mallet", "thumpy")
toolhead("Spade", "crumbly")
toolhead("Hatchet", "choppy")
toolhead("Pick", "cracky")

local function forge(from, fromqty, to, prills)
	return nodecore.register_craft({
			label = "anvil making lode " .. (to or "prills"),
			action = "pummel",
			toolgroups = {thumpy = 3},
			nodes = {
				{
					match = {stack = {name = modname .. ":" .. from .. "_annealed",
							count = fromqty}},
					replace = "air"
				},
				{
					y = -1,
					match = modname .. ":block_tempered"
				}
			},
			items = {
				to and (modname .. ":" .. to .. "_annealed") or nil,
				prills and {name = modname .. ":prill_annealed", count = prills,
					scatter = 5} or nil
			}
		})
end
forge("prill", 3, "toolhead_mallet")
forge("toolhead_mallet", nil, "toolhead_spade", 1)
forge("toolhead_spade", nil, "toolhead_hatchet")
forge("toolhead_hatchet", nil, "toolhead_pick", 1)
forge("toolhead_pick", nil, nil, 1)
