-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function toolhead(name, from, group, sticks)
	local n
	if name then
		n = modname .. ":toolhead_" .. name:lower()
		local t = n:gsub(":", "_") .. ".png"
		minetest.register_craftitem(n, {
				description = "Wooden " .. name .. " Head",
				inventory_image = t,
				stack_max = 1,
				groups = {
					choppy = 1,
					flammable = 2
				}
			})
		local m = modname .. ":tool_" .. name:lower()
		local u = m:gsub(":", "_") .. ".png"
		minetest.register_tool(m, {
				description = "Wooden " .. name,
				inventory_image = u,
				groups = {
					flammable = 2
				},
				tool_capabilities = nodecore.toolcaps({
						[group] = 2
					})
			})
		nodecore.register_craft({
				label = "assemble wood " .. name:lower(),
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

	sticks = sticks and {name = "nc_tree:stick", count = sticks, scatter = 5} or nil
	nodecore.register_craft({
			label = "carve " .. from,
			action = "pummel",
			toolgroups = {choppy = 1},
			nodes = {
				{match = from, replace = "air"}
			},
			items = {
				{name = n},
				sticks
			}
		})
end

toolhead("Mallet", modname .. ":plank",
	"thumpy", 2)
toolhead("Spade", modname .. ":toolhead_mallet",
	"crumbly", 1)
toolhead("Hatchet", modname .. ":toolhead_spade",
	"choppy", 1)
toolhead("Pick", modname .. ":toolhead_hatchet",
	"cracky", 2)
toolhead(nil, modname.. ":toolhead_pick",
	nil, 2)
