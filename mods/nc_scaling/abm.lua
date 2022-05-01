-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_abm({
		label = "scaling decay",
		interval = 1,
		chance = 1,
		nodenames = {"group:" .. modname},
		ignore_stasis = true,
		arealoaded = 1,
		action = function(pos)
			local data = minetest.get_meta(pos):get_string("data")
			if (not data) or (data == "") then
				return minetest.remove_node(pos)
			end
			data = minetest.deserialize(data)
			if minetest.get_node(data.pos).name ~= data.node then
				return minetest.remove_node(pos)
			end
			for _, p in pairs(minetest.get_connected_players()) do
				if nodecore.scaling_closenough(pos, p) then return end
			end
			return minetest.remove_node(pos)
		end
	})

local dntname = modname .. ":particles"
nodecore.register_dnt({
		name = dntname,
		time = 1,
		loop = true,
		autostart = true,
		nodenames = {"group:" .. modname .. "_fx"},
		action = function(pos)
			nodecore.scaling_particles(pos)
			return nodecore.dnt_set(pos, dntname, 1)
		end
	})
