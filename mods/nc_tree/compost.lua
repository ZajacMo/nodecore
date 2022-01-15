-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore
    = ipairs, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":humus", {
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
		sounds = nodecore.sounds("nc_terrain_crunchy")
	})

minetest.register_node(modname .. ":peat", {
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
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

nodecore.register_craft({
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
nodecore.register_craft({
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

nodecore.register_on_peat_compost,
nodecore.registered_on_peat_composts
= nodecore.mkreg()

local function compostdone(pos, node)
	nodecore.set_loud(pos, node)
	for _, f in ipairs(nodecore.registered_on_peat_composts) do f(pos) end
	nodecore.witness(pos, "peat compost")
	return false
end

nodecore.register_soaking_abm({
		label = "peat compost",
		fieldname = "compost",
		nodenames = {modname .. ":peat"},
		interval = 10,
		soakrate = nodecore.tree_soil_rate,
		soakcheck = function(data, pos)
			if data.total < compostcost then return end
			minetest.get_meta(pos):from_table({})
			if math_random(1, 20) == 1 and nodecore.is_full_sun(
				{x = pos.x, y = pos.y + 1, z = pos.z}) then
				return compostdone(pos, {name = "nc_terrain:dirt_with_grass"})
			end
			compostdone(pos, {name = modname .. ":humus"})
			local found = nodecore.find_nodes_around(pos, {modname .. ":peat"})
			if #found < 1 then return false end
			nodecore.soaking_abm_push(nodecore.pickrand(found),
				"compost", data.total - compostcost)
			return false
		end
	})

nodecore.register_craft({
		label = "tickle peat",
		action = "pummel",
		toolgroups = {crumbly = 1},
		nodes = {
			{match = modname .. ":peat"}
		},
		after = function(pos)
			nodecore.soaking_abm_tickle(pos, "compost")
			nodecore.soaking_particles(pos, 25, 0.5, .45, modname .. ":humus")
		end
	})
