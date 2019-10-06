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
			"nc_fire_coal_4.png",
			"nc_tree_tree_top.png",
			"nc_fire_coal_4.png^[lowpart:50:nc_tree_tree_side.png",
			"[combine:1x1"
		},
		selection_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
		collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			snappy = 1,
			falling_repose = 1,
			flammable = 1,
			firestick = 1,
			stack_as_node = 1
		},
		sounds = nodecore.sounds("nc_tree_sticky"),
		on_ignite = function(pos)
			minetest.set_node(pos, {name = modname .. ":torch_lit"})
			minetest.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			local expire = minetest.get_gametime() + nodecore.boxmuller() * 5 + 60
			minetest.get_meta(pos):set_float("expire", expire)
			return true
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

-- Note: Torch dropped as item is sort of unrealistic, perhaps drop as node in future
minetest.register_node(modname .. ":torch_lit", {
		description = "Lit Torch",
		drawtype = "mesh",
		mesh = "nc_torch_torch.obj",
		tiles = {
			"nc_fire_coal_4.png^nc_fire_ember_4.png",
			"nc_tree_tree_top.png",
			"nc_fire_coal_4.png^nc_fire_ember_4.png^[lowpart:50:nc_tree_tree_side.png",
			{
				name = "nc_torch_flame.png",
				animation = {
					["type"] = "vertical_frames",
					aspect_w = 3,
					aspect_h = 8,
					length = 0.6
				}
			}
		},
		selection_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
		collision_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 6/16, 1/16),
		paramtype = "light",
		sunlight_propagates = true,
		light_source = 8,
		groups = {
			snappy = 1,
			falling_repose = 1,
			stack_as_node = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_tree_sticky"),
		preserve_metadata = function(_, _, oldmeta, drops)
			drops[1]:get_meta():set_float("expire", oldmeta.expire)
		end,
		after_place_node = function(pos, _, itemstack)
			minetest.get_meta(pos):set_float("expire",
				itemstack:get_meta():get_float("expire"))
		end
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
