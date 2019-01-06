-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":fire", {
		description = "Fire",
		drawtype = "firelike",
		visual_scale = 1.5,
		tiles = {modname .. "_fire.png"},
		paramtype = "light",
		light_source = 12,
		groups = {
			igniter = 1
		},
		damage_per_second = 2,
		propagates_sunlight = true,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
	})

minetest.register_node(modname .. ":fuel", {
		description = "Burning Embers",
		tiles = {modname .. "_fuel.png"},
		paramtype = "light",
		light_source = 6,
		groups = { 
			igniter = 1,
			fire_fuel = 1,
			falling_node = 1
		},
		drop = "",
		diggable = false,
		on_punch = function(pos, node, puncher)
			puncher:set_hp(puncher:get_hp() - 1)
		end
	})

minetest.register_node(modname .. ":ash", {
		description = "Ash",
		tiles = {modname .. "_ash.png"},
		groups = { falling_node = 1, crumbly = 3 }
	})
