-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":bricks", {
		description = "Stone Bricks",
		tiles = {"nc_terrain_stone.png^" .. modname .. "_bricks.png"},
		groups = {
			stone = 1,
			rock = 1,
			cracky = 2,
			falling_node = 1
		},
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony")
	})

nodecore.register_craft({
		label = "chisel stone into bricks",
		action = "pummel",
		toolgroups = {thumpy = 3},
		normal = {y = 1},
		nodes = {
			{
				match = {
					metal_temper_cool = true,
					groups = {chisel = true}
				},
				dig = true
			},
			{
				y = -1,
				match = {groups = {smoothstone = true}},
				replace = modname .. ":bricks"
			}
		}
	})

minetest.register_node(modname .. ":bricks_bonded", {
		description = "Bonded Stone Bricks",
		tiles = {"nc_terrain_stone.png^(" .. modname .. "_bricks.png^[opacity:128)"},
		groups = {
			stone = 1,
			rock = 1,
			cracky = 3
		},
		crush_damage = 2,
		sounds = nodecore.sounds("nc_terrain_stony")
	})

nodecore.register_limited_abm({
		label = "bond stone bricks",
		nodenames = {modname .. ":bricks"},
		neighbors = {"group:concrete_wet"},
		interval = 1,
		chance = 2,
		action = function(pos)
			nodecore.set_loud(pos, {name = modname .. ":bricks_bonded"})
		end
	})
