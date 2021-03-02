-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_craft({
		label = "craft tote handle",
		norotate = true,
		indexkeys = {"nc_woodwork:frame"},
		nodes = {
			{match = "nc_woodwork:frame", replace = "air"},
			{y = -1, match = "nc_lode:block_annealed", replace = modname .. ":handle"},
			{y = -1, x = 1, match = {groups = {totable = true}}},
			{y = -1, x = -1, match = {groups = {totable = true}}},
			{y = -1, z = 1, match = {groups = {totable = true}}},
			{y = -1, z = -1, match = {groups = {totable = true}}},
		}
	})

nodecore.register_craft({
		label = "break apart tote",
		action = "pummel",
		toolgroups = {choppy = 5},
		check = function(pos, data)
			if data.node.name == modname .. ":handle" then return true end
			local stack = nodecore.stack_get(pos)
			if stack:get_name() ~= modname .. ":handle" then return end
			return (stack:get_meta():get_string("carrying") or "") == ""
		end,
		indexkeys = {modname .. ":handle"},
		nodes = {
			{
				match = modname .. ":handle",
				replace = "air"
			}
		},
		items = {
			{name = "nc_lode:prill_annealed 2", count = 4, scatter = 5}
		}
	})
