-- LUALOCALS < ---------------------------------------------------------
local core, nc, string, tonumber
    = core, nc, string, tonumber
local string_sub
    = string.sub
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.torch_life_base = 120
function nc.get_torch_expire(meta, name)
	local expire = meta:get_float("expire") or 0
	if expire > 0 then return expire end
	local ttl = nc.torch_life_base
	* (nc.boxmuller() * 0.1 + 1)
	if name then
		local id = tonumber(string_sub(name, -1))
		if id and id > 1 then
			ttl = ttl * 0.5 ^ (id - 1)
		end
	end
	expire = nc.gametime + ttl
	meta:set_float("expire", expire)
	return expire, true
end

core.register_node(modname .. ":torch", {
		description = "Torch",
		drawtype = "mesh",
		mesh = "nc_torch_torch.obj",
		tiles = {
			"nc_fire_coal_4.png",
			"nc_tree_tree_top.png",
			"nc_fire_coal_4.png^[lowpart:50:nc_tree_tree_side.png",
			"[combine:1x1"
		},
		backface_culling = true,
		use_texture_alpha = "clip",
		selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
		collision_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			snappy = 1,
			falling_repose = 1,
			flammable = 1,
			firestick = 3,
			stack_as_node = 1,
			optic_opaque = 1,
		},
		sounds = nc.sounds("nc_tree_sticky"),
		on_ignite = function(pos, node)
			core.set_node(pos, {name = modname .. ":torch_lit"})
			nc.get_torch_expire(core.get_meta(pos))
			nc.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			if node and node.count and node.count > 1 then
				nc.item_disperse(pos, node.name, node.count - 1)
			end
			return true
		end,
		mapcolor = {a = 0},
	})

nc.register_craft({
		label = "assemble torch",
		normal = {y = 1},
		indexkeys = {"nc_fire:lump_coal"},
		nodes = {
			{match = "nc_fire:lump_coal", replace = "air"},
			{y = -1, match = "nc_woodwork:staff", replace = modname .. ":torch"},
		}
	})

nc.torch_life_stages = 4
for i = 1, nc.torch_life_stages do
	local alpha = (i - 1) * (256 / nc.torch_life_stages)
	if alpha > 255 then alpha = 255 end
	local txr = "nc_fire_coal_4.png^nc_fire_ember_4.png^(nc_fire_ash.png^[opacity:"
	.. alpha .. ")"
	core.register_node(modname .. ":torch_lit_" .. i, {
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
			backface_culling = true,
			use_texture_alpha = "clip",
			selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
			collision_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
			paramtype = "light",
			sunlight_propagates = true,
			light_source = 8 - i,
			groups = {
				snappy = 1,
				falling_repose = 1,
				stack_as_node = 1,
				torch_lit = 1,
				flame_ambiance = 1,
				optic_opaque = 1,
			},
			stack_max = 1,
			sounds = nc.sounds("nc_tree_sticky"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				core.get_meta(pos):from_table(itemstack:get_meta():to_table())
			end,
			node_dig_prediction = nc.dynamic_light_node(8 - i),
			after_destruct = function(pos)
				nc.dynamic_light_add(pos, 8 - i)
			end,
			mapcolor = {a = 0},
		})
end
core.register_alias(modname .. ":torch_lit", modname .. ":torch_lit_1")
