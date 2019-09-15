-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":torch", {
	description = "Torch",
	drawtype = "mesh",
	mesh = "nc_torch_torch.obj",
	tiles = {
		"nc_torch_coal.png",
		"nc_tree_tree_top.png",
		"nc_torch_coal.png^[lowpart:50:nc_tree_tree_side.png",
		"[combine:1x1"
	},
	selection_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
	collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
	paramtype = "light",
	sunlight_propagates = true,
	groups = {
		snappy = 1,
		falling_repose = 2,
		flammable = 3,
	},
	sounds = nodecore.sounds("nc_tree_sticky"),
	on_ignite = function(pos)
		if minetest.get_node(vector.add(pos, {x = 0, y = 1, z = 0})).name ~= "air" then
			return true
		end
		minetest.set_node(pos, {name = modname .. ":torch_lit"})
		local expire = minetest.get_gametime() + math.random(20, 120)
		minetest.get_meta(pos):set_int("expire", expire)
		return true
	end
})

minetest.register_node(modname .. ":torch_lit", {
	description = "Lit Torch",
	drawtype = "mesh",
	mesh = "nc_torch_torch.obj",
	tiles = {
		"nc_torch_coal.png",
		"nc_tree_tree_top.png",
		"nc_torch_coal.png^[lowpart:50:nc_tree_tree_side.png",
		"nc_torch_flame.png"
	},
	selection_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
	collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 8,
	groups = {
		snappy = 1,
		falling_repose = 2,
	},
	stack_max = 1,
	sounds = nodecore.sounds("nc_tree_sticky"),
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		drops[1]:get_meta():set_int("expire", oldmeta.expire)
	end,
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_int("expire", itemstack:get_meta():get_int("expire"))
	end
})

nodecore.register_craft({
	label = "assemble torch",
	normal = {y = 1},
	nodes = {
		{match = "nc_fire:lump_coal", replace = "air"},
		{y = -1, match = "nc_woodwork:staff", replace = modname .. ":torch"},
	}
})

minetest.register_node(modname .. ":wield_light", {
	drawtype = "airlike",
	paramtype = "light",
	light_source = 8,
	pointable = false,
	walkable = false,
	on_timer = function(pos)
		minetest.set_node(pos, {name = "air"})
	end,
})
