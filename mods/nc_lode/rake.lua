-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local loosevol = nodecore.rake_volume(2, 1)
local loosetest = nodecore.rake_index(function(def)
		return def.groups and def.groups.falling_node
		and def.groups.snappy == 1
	end)
local snapvol = nodecore.rake_volume(1, 1)
local crumbvol = nodecore.rake_volume(1, 0)
local function mkonrake(toolcaps)
	local snaptest = nodecore.rake_index(function(def)
			return def.groups and def.groups.snappy
			and def.groups.snappy <= toolcaps.opts.snappy
		end)
	local crumbtest = nodecore.rake_index(function(def)
			return def.groups and def.groups.crumbly
			and def.groups.crumbly <= toolcaps.opts.crumbly
		end)
	return function(pos, node)
		if loosetest(pos, node) then return loosevol, loosetest end
		if snaptest(pos, node) then return snapvol, snaptest end
		if crumbtest(pos, node) then return crumbvol, crumbtest end
	end
end
nodecore.lode_rake_function = mkonrake

nodecore.register_lode("rake", {
		type = "tool",
		description = "## Lode Rake",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_rake.png",
		stack_max = 1,
		light_source = 3,
		bytemper = function(t, d)
			local dlv = 0
			if t.name == "tempered" then
				dlv = 1
			elseif t.name == "hot" then
				dlv = -1
			end
			d.tool_capabilities = nodecore.toolcaps({
					snappy = 1,
					crumbly = 1 + dlv,
					uses = 20 + 5 * dlv
				})
			d.on_rake = mkonrake(d.tool_capabilities)
		end,
		groups = {rakey = 2},
		tool_wears_to = modname .. ":prill_# 10"
	})

nodecore.register_lode_anvil_recipe(-2, function(temper)
		local adze = {name = modname .. ":adze_" .. temper, wear = 0.05}
		return {
			label = "assemble lode rake",
			action = "pummel",
			toolgroups = {thumpy = 3},
			priority = 1,
			indexkeys = {modname .. ":adze_" .. temper},
			nodes = {
				{match = adze, replace = "air"},
				{y = -1, match = modname .. ":rod_" .. temper, replace = "air"},
				{x = -1, match = adze, replace = "air"},
				{x = 1, match = adze, replace = "air"},
			},
			items = {{
					y = -1,
					name = modname .. ":rake_annealed"
			}}
		}
	end)

nodecore.register_craft({
		label = "recycle lode rake",
		action = "pummel",
		toolgroups = {choppy = 3},
		indexkeys = {modname .. ":rake_hot"},
		nodes = {
			{
				match = modname .. ":rake_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":bar_hot", count = 3},
			{name = modname .. ":rod_hot", count = 4}
		}
	})
