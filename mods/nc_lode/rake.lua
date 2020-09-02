-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local rakable = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups then
				if v.groups.damage_touch then
					rakable[k] = nil
				elseif v.groups.snappy == 1 then
					rakable[k] = true
				elseif v.groups.crumbly then
					rakable[k] = v.groups.crumbly
				end
			end
		end
	end)

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
			d.rake_check = function(itemname, rel)
				local r = rakable[itemname]
				if not r then return end
				if r == true then return true end
				if rel.rxz > 1 or rel.ry > 0 then return end
				return r <= (1 + dlv) or nil
			end
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
