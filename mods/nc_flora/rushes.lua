-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random, math_sqrt
    = math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":rush", {
		description = "Rush",
		drawtype = "plantlike",
		waving = 1,
		tiles = {modname .. "_rush_side.png"},
		inventory_image = modname .. "_rush_inv.png",
		wield_image = modname .. "_rush_inv.png",
		wield_scale = {x = 1.2, y = 1.2, z = 1.2},
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 4,
		sunlight_propagates = true,
		walkable = false,
		groups = {
			snappy = 1,
			flora = 1,
			flammable = 3,
			attached_node = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

minetest.register_node(modname .. ":rush_dry", {
		description = "Dry Rush",
		drawtype = "plantlike",
		waving = 1,
		tiles = {modname .. "_rush_side_dry.png"},
		inventory_image = modname .. "_rush_inv_dry.png",
		wield_image = modname .. "_rush_inv_dry.png",
		wield_scale = {x = 1.2, y = 1.2, z = 1.2},
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 4,
		sunlight_propagates = true,
		walkable = false,
		groups = {
			snappy = 1,
			flammable = 2,
			attached_node = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

minetest.register_decoration({
		name = modname .. ":rush",
		deco_type = "simple",
		place_on = {"group:soil", "group:sand"},
		sidelen = 4,
		noise_params = {
			offset = -0.4,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		y_max = 3,
		y_min = 1,
		spawn_by = {"group:moist", modname .. ":rush"},
		num_spawn_by = 1,
		decoration = {modname .. ":rush"},
		param2 = 4,
	})

local function rushdie(pos)
	return nodecore.set_loud(pos, {name = modname .. ":rush_dry", param2 = 4})
end

nodecore.register_limited_abm({
		label = "rush dry",
		interval = 1,
		chance = 25,
		nodenames = {modname .. ":rush"},
		action = function(pos)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bnode = minetest.get_node_or_nil(below)
			if not bnode then return end
			if minetest.get_item_group(bnode.name, "soil")
			+ minetest.get_item_group(bnode.name, "sand") < 1 then
				return rushdie(pos)
			end
			if #nodecore.find_nodes_around(pos, "group:moist", 2) < 1 then
				return rushdie(pos)
			end
		end
	})

nodecore.register_aism({
		label = "rush stack dry",
		interval = 1,
		chance = 25,
		itemnames = {modname .. ":rush"},
		action = function(stack, data)
			local moist = 0
			local dirt = 0
			if data.player and data.list == "main" and data.slot then
				local inv = data.player:get_inventory()
				for i = 1, inv:get_size(data.list) do
					local item = inv:get_stack(data.list, i):get_name()
					moist = moist + minetest.get_item_group(item, "moist")
					dirt = dirt + minetest.get_item_group(item, "soil")
					dirt = dirt + minetest.get_item_group(item, "sand")
				end
			end
			if math_random() * 12 < math_sqrt(dirt * moist) then return end
			nodecore.sound_play("nc_terrain_swishy", {pos = data.pos})
			local taken = stack:take_item(1)
			taken:set_name(modname .. ":rush_dry")
			if data.inv then taken = data.inv:add_item("main", taken) end
			if not taken:is_empty() then nodecore.item_eject(data.pos, taken) end
			return stack
		end
	})
