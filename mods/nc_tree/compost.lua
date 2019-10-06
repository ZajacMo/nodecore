-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":humus", {
		description = "Humus",
		tiles = {modname .. "_humus.png"},
		groups = {
			dirt = 2,
			crumbly = 1,
			soil = 4
		},
		alternate_loose = {
			groups = {
				dirt_loose = 2,
				soil = 5
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
			green = 1
		},
		crush_damage = 1,
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

nodecore.register_craft({
		label = "compress peat block",
		action = "pummel",
		toolgroups = {crumbly = 1},
		nodes = {
			{
				match = {name = modname .. ":leaves_loose", count = 8},
				replace = modname .. ":peat"
			}
		}
	})

nodecore.register_soaking_abm({
		label = "Composting Growing",
		nodenames = {modname .. ":peat"},
		neighbors = {"group:soil"},
		interval = 10,
		chance = 10,
		limited_max = 100,
		limited_alert = 1000,
		soakrate = function(pos)
			local d = 0
			local w = 1
			nodecore.scan_flood(pos, 3, function(p, r)
					if r < 1 then return end
					local nn = minetest.get_node(p).name
					local def = minetest.registered_items[nn] or {}
					if not def.groups then
						return false
					end
					if def.groups.soil then
						d = d + def.groups.soil
						w = w + 0.2
					elseif def.groups.moist then
						w = w + def.groups.moist
						return false
					else
						return false
					end
				end)
			return math_sqrt(d * w)
		end,
		soakcheck = function(data, pos)
			if data.total < 5000 then return end
			minetest.set_node(pos, {name = modname .. ":humus"})
			nodecore.node_sound(pos, "place")
		end
	})
