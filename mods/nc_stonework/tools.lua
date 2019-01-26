-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, type
    = ipairs, minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_stone_tip_tool,
nodecore.registered_stone_tip_tools
= nodecore.mkreg()

local chip = modname .. ":chip"
nodecore.extend_item(chip, function(copy, orig)
		copy.on_place = function(itemstack, placer, pointed_thing, ...)
			if itemstack:get_name() == chip and pointed_thing.type == "node" then
				local pos = pointed_thing.under
				for i, v in ipairs(nodecore.registered_stone_tip_tools) do
					if nodecore.node_is(pos, {visinv = {
								name = v.from,
								wear = 0.02
							}}) then
						minetest.remove_node(pos)
						nodecore.item_eject(pos, v.to)
						itemstack:set_count(itemstack:get_count() - 1)
						return itemstack
					end
				end
			end
			return orig.on_place(itemstack, placer, pointed_thing, ...)
		end
	end)

local function tooltip(name, group)
	local tool = modname .. ":tool_" .. name:lower()
	local wood = "nc_woodwork:tool_" .. name:lower()
	minetest.register_tool(tool, {
			description = "Stone-Tipped " .. name,
			inventory_image = "nc_woodwork_tool_" .. name:lower() .. ".png^"
			.. modname .. "_tip_" .. name:lower() .. ".png",
			tool_wears_to = wood,
			groups = {
				flammable = 2
			},
			tool_capabilities = nodecore.toolcaps({
					uses = 0.25,
					[group] = 3
				})
		})
	nodecore.register_stone_tip_tool({from = wood, to = tool})
end

tooltip("Mallet", "thumpy")
tooltip("Spade", "crumbly")
tooltip("Hatchet", "choppy")
tooltip("Pick", "cracky")
