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
			igniter = 1,
			flame = 1
		},
		damage_per_second = 2,
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
	})

local function ember(n, t)
	minetest.register_node(modname .. ":ember" .. n, {
			description = "Burning Embers",
			tiles = {t},
			paramtype = "light",
			light_source = 6,
			groups = { 
				igniter = 1,
				ember = n,
				falling_node = 1
			},
			drop = "",
			diggable = false,
			on_punch = function(pos, node, puncher)
				puncher:set_hp(puncher:get_hp() - 1)
			end,
			crush_damage = 1
		})
end
ember(1, modname .. "_ash.png^(" .. modname .. "_ember1.png^[opacity:128)")
ember(2, modname .. "_ash.png^" .. modname .. "_ember1.png")
ember(3, modname .. "_ash.png^" .. modname .. "_ember1.png^(" .. modname .. "_ember2.png^[opacity:128)")
ember(4, modname .. "_ash.png^" .. modname .. "_ember2.png")
ember(5, modname .. "_ash.png^" .. modname .. "_ember2.png^(" .. modname .. "_ember3.png^[opacity:128)")
ember(6, modname .. "_ember3.png")
minetest.register_alias(modname .. ":fuel", modname .. ":ember2")

minetest.register_node(modname .. ":ash", {
		description = "Ash",
		tiles = {modname .. "_ash.png"},
		groups = {
			falling_node = 1,
			falling_repose = 1,
			crumbly = 1
		},
		crush_damage = 0.25
	})
