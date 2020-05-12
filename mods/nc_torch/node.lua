-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.torch_life_base = 120
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
			firestick = 3,
			stack_as_node = 1
		},
		sounds = nodecore.sounds("nc_tree_sticky"),
		on_ignite = function(pos, node)
			minetest.set_node(pos, {name = modname .. ":torch_lit"})
			nodecore.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			local expire = nodecore.gametime + nodecore.torch_life_base
			* (nodecore.boxmuller() * 0.1 + 1)
			minetest.get_meta(pos):set_float("expire", expire)
			if node and node.count and node.count > 1 then
				nodecore.item_disperse(pos, node.name, node.count - 1)
			end
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

nodecore.torch_life_stages = 4
for i = 1, nodecore.torch_life_stages do
	local alpha = (i - 1) * (256 / nodecore.torch_life_stages)
	if alpha > 255 then alpha = 255 end
	local txr = "nc_fire_coal_4.png^nc_fire_ember_4.png^(nc_fire_ash.png^[opacity:"
	.. alpha .. ")"
	minetest.register_node(modname .. ":torch_lit_" .. i, {
			description = "Lit Torch",
			drawtype = "mesh",
			mesh = "nc_torch_torch.obj",
			tiles = {
				txr,
				"nc_tree_tree_top.png",
				txr .. "^[lowpart:50:nc_tree_tree_side.png",
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
			light_source = 8 - i,
			groups = {
				snappy = 1,
				falling_repose = 1,
				stack_as_node = 1,
				torch_lit = 1
			},
			stack_max = 1,
			sounds = nodecore.sounds("nc_tree_sticky"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				minetest.get_meta(pos):from_table(itemstack:get_meta():to_table())
			end,
			node_dig_prediction = nodecore.dynamic_light_node(8),
			after_destruct = function(pos)
				nodecore.dynamic_light_add(pos, 8, 0.5)
			end
		})
end
minetest.register_alias(modname .. ":torch_lit", modname .. ":torch_lit_1")
