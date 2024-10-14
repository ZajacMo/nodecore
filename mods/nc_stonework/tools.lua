-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local function tooltip(name, group)
	local tool = modname .. ":tool_" .. name:lower()
	local wood = "nc_woodwork:tool_" .. name:lower()
	core.register_tool(tool, {
			description = "Stone-Tipped " .. name,
			inventory_image = "nc_woodwork_tool_" .. name:lower() .. ".png^"
			.. modname .. "_tip_" .. name:lower() .. ".png",
			tool_wears_to = wood,
			groups = {
				flammable = 2
			},
			tool_capabilities = nc.toolcaps({
					uses = 0.25,
					[group] = 3
				}),
			on_ignite = modname .. ":chip",
			sounds = nc.sounds("nc_terrain_stony")
		})
	local woodmatch = {name = wood, wear = 0.05}
	nc.register_craft({
			label = "assemble " .. tool,
			action = "stackapply",
			wield = {name = modname .. ":chip"},
			consumewield = 1,
			indexkeys = {wood},
			nodes = {{match = woodmatch, replace = "air"}},
			items = {tool}
		})
end

tooltip("Mallet", "thumpy")
tooltip("Spade", "crumbly")
tooltip("Hatchet", "choppy")
tooltip("Pick", "cracky")
