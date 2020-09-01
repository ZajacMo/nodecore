-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function lodzecaps(lv)
	return nodecore.toolcaps({
			choppy = lv,
			crumbly = lv,
			cracky = lv - 2
		})
end
nodecore.register_lode("adze", {
		type = "tool",
		description = "## Lode Adze",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_adze.png",
		stack_max = 1,
		light_source = 3,
		tool_capabilities = lodzecaps(3),
		bytemper = function(t, d)
			if t.name == "tempered" then
				d.tool_capabilities = lodzecaps(4)
			elseif t.name == "hot" then
				d.tool_capabilities = lodzecaps(2)
			end
		end,
		tool_wears_to = modname .. ":prill_# 3"
	})

nodecore.register_craft({
		label = "anvil making lode adze",
		action = "pummel",
		toolgroups = {thumpy = 3},
		indexkeys = {modname .. ":bar_annealed"},
		nodes = {
			{
				match = {name = modname .. ":bar_annealed"},
				replace = "air"
			},
			{
				y = -1,
				match = {name = modname .. ":rod_annealed"},
				replace = "air"
			},
			{
				y = -2,
				match = modname .. ":block_tempered"
			}
		},
		items = {
			modname .. ":adze_annealed"
		}
	})
nodecore.register_craft({
		label = "recycle lode adze",
		action = "pummel",
		toolgroups = {choppy = 3},
		indexkeys = {modname .. ":adze_hot"},
		nodes = {
			{
				match = modname .. ":adze_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":bar_hot"},
			{name = modname .. ":rod_hot"}
		}
	})
