-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_craft({
		label = "craft tote handle",
		action = "stackapply",
		indexkeys = {"nc_lode:form"},
		wield = {name = "nc_lode:frame_annealed"},
		consumewield = 1,
		nodes = {
			{
				match = {name = "nc_lode:form", empty = true},
				replace = modname .. ":handle"
			},
		}
	})

nc.register_craft({
		label = "break apart tote",
		action = "pummel",
		toolgroups = {choppy = 5},
		check = function(pos, data)
			if data.node.name == modname .. ":handle" then return true end
			local stack = nc.stack_get(pos)
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
			{name = "nc_lode:bar_annealed 2", count = 4, scatter = 5}
		}
	})
