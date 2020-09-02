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
local snaptest = nodecore.rake_index(function(def)
		return def.groups and def.groups.snappy == 1
	end)
local crumbvol = nodecore.rake_volume(1, 0)
local function mkonrake(crumblv)
	local crumbtest = nodecore.rake_index(function(def)
			return def.groups and def.groups.crumbly
			and def.groups.crumbly <= crumblv
		end)
	return function(pos, node)
		if loosetest(pos, node) then return loosevol, loosetest end
		if snaptest(pos, node) then return snapvol, snaptest end
		if crumbtest(pos, node) then return crumbvol, crumbtest end
	end
end

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
			d.on_rake = mkonrake(1 + dlv)
		end,
		tool_wears_to = modname .. ":prill_# 13"
	})

local adze = {name = modname .. ":adze_annealed", wear = 0.05}
nodecore.register_craft({
		label = "assemble lode rake",
		action = "pummel",
		toolgroups = {thumpy = 3},
		norotate = true,
		priority = 1,
		indexkeys = {modname .. ":bar_annealed"},
		nodes = {
			{match = modname .. ":bar_annealed", replace = "air"},
			{y = -1, match = modname .. ":block_tempered"},
			{x = 0, z = -1, match = adze, replace = "air"},
			{x = 0, z = 1, match = adze, replace = "air"},
			{x = -1, z = 0, match = adze, replace = "air"},
			{x = 1, z = 0, match = adze, replace = "air"},
		},
		items = {
			modname .. ":rake_annealed"
		}
	})
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
			{name = modname .. ":bar_hot", count = 5},
			{name = modname .. ":rod_hot", count = 4}
		}
	})
