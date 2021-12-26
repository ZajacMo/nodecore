-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_random
    = math.random
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
		sounds = nodecore.sounds("nc_terrain_swishy"),
		selection_box = nodecore.fixedbox({-3/8, -1/2, -3/8, 3/8, 1/4, 3/8})
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
			attached_node = 1,
			flora_dry = 1,
			peat_grindable_item = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy"),
		selection_box = nodecore.fixedbox({-3/8, -1/2, -3/8, 3/8, 1/4, 3/8})
	})

minetest.register_decoration({
		name = modname .. ":rush",
		deco_type = "simple",
		place_on = {"group:soil", "group:sand"},
		sidelen = 4,
		noise_params = {
			offset = -0.5,
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

local rush_substrate = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.soil or v.groups.sand then
				rush_substrate[k] = v.soil_degrades_to or true
			end
		end
	end)

local function rushcheck(pos)
	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	local bnode = minetest.get_node_or_nil(below)
	if not bnode then return end
	local subst = rush_substrate[bnode.name]
	if not subst then return false end
	if #nodecore.find_nodes_around(pos, "group:moist", 2) < 1 then
		return false
	end
	return subst, below
end
minetest.register_abm({
		label = "rush drying/spreading",
		interval = 1,
		chance = 50,
		arealoaded = 2,
		nodenames = {modname .. ":rush"},
		action = function(pos)
			local subst, below = rushcheck(pos)
			if subst == false then
				return nodecore.set_loud(pos, {
						name = modname .. ":rush_dry",
						param2 = 4
					})
			end
			if subst == true then return end
			if math_random(1, 15) ~= 1 then return end
			local pick = {
				x = pos.x + math_random(-1, 1),
				y = pos.y + math_random(-1, 1),
				z = pos.z + math_random(-1, 1),
			}
			if not (nodecore.air_equivalent(pick)
				and rushcheck(pick)) then return end
			if math_random(1, 4) == 1 then
				nodecore.set_loud(below, {name = subst})
			end
			nodecore.set_loud(pick, {
					name = modname .. ":rush",
					param2 = 4
				})
			return nodecore.witness(pick, "rush spread")
		end
	})

nodecore.register_aism({
		label = "rush stack dry",
		interval = 1,
		chance = 25,
		arealoaded = 2,
		itemnames = {modname .. ":rush"},
		action = function(stack, data)
			if data.toteslot then return end
			if data.player and data.list then
				local inv = data.player:get_inventory()
				for i = 1, inv:get_size(data.list) do
					local item = inv:get_stack(data.list, i):get_name()
					if minetest.get_item_group(item, "moist") > 0 then return end
				end
			end
			if #nodecore.find_nodes_around(data.pos, "group:moist", 2) > 0 then return end
			nodecore.sound_play("nc_terrain_swishy", {pos = data.pos})
			local taken = stack:take_item(1)
			taken:set_name(modname .. ":rush_dry")
			if data.inv then taken = data.inv:add_item("main", taken) end
			if not taken:is_empty() then nodecore.item_eject(data.pos, taken) end
			return stack
		end
	})
