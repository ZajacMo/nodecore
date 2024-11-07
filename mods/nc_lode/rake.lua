-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local loosevol = nc.rake_volume(2, 1)
local loosetest = nc.rake_index(function(def)
		return def.groups and def.groups.falling_node
		and def.groups.snappy == 1
	end)
local snapvol = nc.rake_volume(1, 1)
local crumbvol = nc.rake_volume(1, 0)
local function mkonrake(toolcaps)
	local snaptest = nc.rake_index(function(def)
			return def.groups and def.groups.snappy
			and def.groups.snappy <= toolcaps.opts.snappy
		end)
	local crumbtest = nc.rake_index(function(def)
			return def.groups and def.groups.crumbly
			and def.groups.crumbly <= toolcaps.opts.crumbly
		end)
	return function(pos, node)
		if loosetest(pos, node) then return loosevol, loosetest end
		if snaptest(pos, node) then return snapvol, snaptest end
		if crumbtest(pos, node) then return crumbvol, crumbtest end
	end
end
nc.lode_rake_function = mkonrake

nc.register_lode("rake", {
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
			d.tool_capabilities = nc.toolcaps({
					snappy = 1,
					crumbly = 1 + dlv,
					uses = 20 + 5 * dlv
				})
			d.on_rake = mkonrake(d.tool_capabilities)
		end,
		groups = {
			rakey = 2,
			nc_doors_pummel_first = 1
		},
		tool_wears_to = modname .. ":prill_# 10"
	})

nc.register_lode_anvil_recipe(-2, function(temper)
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

nc.register_craft({
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
