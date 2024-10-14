-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc
    = core, ipairs, math, nc
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":humus", {
		description = "Humus",
		tiles = {modname .. "_humus.png"},
		groups = {
			humus = 1,
			crumbly = 1,
			soil = 4,
			grassable = 1
		},
		soil_degrades_to = "nc_terrain:dirt",
		alternate_loose = {
			soil_degrades_to = "nc_terrain:dirt_loose",
			groups = {
				dirt_loose = 2,
				soil = 5,
				grassable = 1,
				falling_repose = 1
			}
		},
		crush_damage = 1,
		sounds = nc.sounds("nc_terrain_crunchy"),
		mapcolor = {r = 68, g = 43, b = 15},
	})

core.register_node(modname .. ":peat", {
		description = "Peat",
		tiles = {modname .. "_humus.png^" .. modname .. "_peat.png^nc_api_loose.png"},
		groups = {
			falling_repose = 1,
			crumbly = 1,
			flammable = 1,
			fire_fuel = 3,
			moist = 1,
			green = 1
		},
		crush_damage = 1,
		sounds = nc.sounds("nc_terrain_swishy"),
		mapcolor = {r = 68, g = 43, b = 15},
	})

nc.register_craft({
		label = "compress peat block",
		action = "pummel",
		toolgroups = {crumbly = 2},
		indexkeys = {"group:peat_grindable_item"},
		nodes = {
			{
				match = {groups = {peat_grindable_item = true}, count = 8},
				replace = modname .. ":peat"
			}
		}
	})
nc.register_craft({
		label = "compress peat block",
		action = "pummel",
		toolgroups = {crumbly = 2},
		indexkeys = {"group:peat_grindable_node"},
		nodes = {
			{
				match = {groups = {peat_grindable_node = true}, count = 1},
				replace = modname .. ":peat"
			}
		}
	})

local compostcost = 2500

nc.register_on_peat_compost,
nc.registered_on_peat_composts
= nc.mkreg()

local function compostdone(pos, node)
	nc.set_loud(pos, node)
	for _, f in ipairs(nc.registered_on_peat_composts) do f(pos) end
	nc.witness(pos, "peat compost")
	return false
end

nc.register_soaking_abm({
		label = "peat compost",
		fieldname = "compost",
		nodenames = {modname .. ":peat"},
		interval = 10,
		soakrate = function(pos)
			return nc.tree_soil_rate(pos, 0, 1)
		end,
		soakcheck = function(data, pos)
			if data.total < compostcost then return end
			core.get_meta(pos):from_table({})
			if math_random(1, 20) == 1 and nc.is_full_sun(
				{x = pos.x, y = pos.y + 1, z = pos.z}) then
				return compostdone(pos, {name = "nc_terrain:dirt_with_grass"})
			end
			compostdone(pos, {name = modname .. ":humus"})
			local found = nc.find_nodes_around(pos, {modname .. ":peat"})
			if #found < 1 then return false end
			nc.soaking_abm_push(nc.pickrand(found),
				"compost", data.total - compostcost)
			return false
		end
	})

nc.register_craft({
		label = "tickle peat",
		action = "pummel",
		toolgroups = {cuddly = 1},
		nodes = {
			{match = {name = modname .. ":peat", stacked = false}}
		},
		after = function(pos)
			nc.soaking_abm_tickle(pos, "compost")
			nc.soaking_particles(pos, 25, 0.5, .45, modname .. ":humus")
		end
	})
