-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs
    = core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_abm({
		label = "scaling decay",
		interval = 1,
		chance = 1,
		nodenames = {"group:" .. modname},
		ignore_stasis = true,
		arealoaded = 1,
		action = function(pos)
			local data = core.get_meta(pos):get_string("data")
			if (not data) or (data == "") then
				return core.remove_node(pos)
			end
			data = core.deserialize(data)
			if core.get_node(data.pos).name ~= data.node then
				return core.remove_node(pos)
			end
			for _, p in pairs(core.get_connected_players()) do
				if nc.scaling_closenough(pos, p) then return end
			end
			return core.remove_node(pos)
		end
	})

local dntname = modname .. ":particles"
nc.register_dnt({
		name = dntname,
		time = 1,
		loop = true,
		autostart = true,
		nodenames = {"group:" .. modname .. "_fx"},
		action = function(pos)
			nc.scaling_particles(pos)
			return nc.dnt_set(pos, dntname, 1)
		end
	})
