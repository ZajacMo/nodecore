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
		light_source = 12,
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

nodecore.register_limited_abm({
		label = "Torch expiration",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":torch_lit"},
		action = function(pos, node)
			if minetest.get_gametime() > minetest.get_meta(pos):get_int("expire") then
				minetest.set_node(pos, {name = "air"})
				minetest.add_item(pos, {name = "nc_fire:lump_ash"})
			end
		end
	})

local timer = 0
minetest.register_globalstep(function(dt)
	timer = timer + dt
	if timer > 1 then
		for _, player in pairs(minetest.get_connected_players()) do
			local inv = player:get_inventory()
			if inv:contains_item("main", modname .. ":torch_lit") then
				local list = inv:get_list("main")
				for i, stack in pairs(list) do
					if stack:get_name() == modname .. ":torch_lit" then
						if minetest.get_gametime() > stack:get_meta():get_int("expire") then
							inv:set_stack("main", i, "nc_fire:lump_ash")
						end
					end
				end
			end
		end
	end
end)

nodecore.register_limited_abm({
	label = "Torch igniting",
	interval = 6,
	chance = 1,
	nodenames = {modname .. ":torch_lit"},
	neighbors = {"group:flammable"},
	action = function(pos, node)
		local check = {
			{x = 1, y = 0, z = 0},
			{x = -1, y = 0, z = 0},
			{x = 0, y = 0, z = 1},
			{x = 0, y = 0, z = -1},
			{x = 0, y = 1, z = 0}
		}
		for _, ofst in pairs(check) do
			local npos = vector.add(pos, ofst)
			local nbr = minetest.get_node(npos)
			if minetest.get_node_group(nbr.name, "flammable") > 0 then
				nodecore.fire_check_ignite(npos, nbr)
			end
		end
	end
})
