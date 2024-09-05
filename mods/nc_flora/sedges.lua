-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local grassname = "nc_terrain:dirt_with_grass"

local sedge1 = modname .. ":sedge_1"
local droprates = {
	{{items = {sedge1}, rarity = 16}},
	{{items = {sedge1}, rarity = 8}},
	{{items = {sedge1}, rarity = 4}},
	{{items = {sedge1}, rarity = 2}},
	{
		{items = {sedge1 .. " 2"}, rarity = 2},
		{items = {sedge1}, rarity = 1}
	}
}

local tilebase = modname .. "_sedge_color.png^(nc_terrain_grass_top.png^[mask:"
.. modname .. "_grass_mask.png)"

local allsedges = {}
for i = 1, 5 do
	local sedgename = modname .. ":sedge_" .. i
	allsedges[sedgename] = i
	allsedges[i] = sedgename
	local h = (i == 5) and (3/4) or (i / 8)
	minetest.register_node(sedgename, {
			description = "Sedge",
			drawtype = "plantlike",
			waving = 1,
			inventory_image = modname .. "_sedge_item.png",
			wield_image = modname .. "_sedge_item.png",
			tiles = {
				tilebase .. "^[mask:" .. modname
				.. "_sedge_mask" .. i .. ".png"
			},
			paramtype = "light",
			paramtype2 = "meshoptions",
			place_param2 = 2,
			sunlight_propagates = true,
			walkable = false,
			floodable = true,
			groups = {
				snappy = 1,
				flora = 1,
				flora_sedges = i,
				flora_dry = 1,
				flammable = 3,
				attached_node = 1,
				peat_grindable_item = 1,
				optic_opaque = i == 5 and 1 or nil,
			},
			sounds = nodecore.sounds("nc_terrain_grassy"),
			selection_box = nodecore.fixedbox(
				{-3/8, -1/2, -3/8, 3/8, -1/2 + h, 3/8}
			),
			stack_family = modname .. ":sedge_1",
			drop = {max_items = 1, items = droprates[i]},
			destroy_on_dig = 20,
			after_place_node = function(pos)
				local node = minetest.get_node(pos)
				if node.name ~= sedgename then return end
				local r = math_random(1, 15)
				if r >= 8 then
					node.name = modname .. ":sedge_1"
				elseif r >= 4 then
					node.name = modname .. ":sedge_2"
				elseif r >= 2 then
					node.name = modname .. ":sedge_3"
				else
					node.name = modname .. ":sedge_4"
				end
				if node.name == sedgename then return end
				nodecore.set_node_check(pos, node)
			end,
			mapcolor = {r = 80, g = 106, b = 50, a = 128},
		})

	minetest.register_decoration({
			name = modname .. ":sedge_" .. i,
			deco_type = "simple",
			place_on = {grassname},
			sidelen = 1,
			noise_params = {
				offset = -0.05,
				scale = 0.1,
				spread = {x = 100, y = 100, z = 100},
				seed = 1572,
				octaves = 3,
				persist = 0.7
			},
			decoration = {modname .. ":sedge_" .. i},
			param2 = 2,
		})

end

nodecore.register_on_nodeupdate({
		ignore = {
			stack_set = true,
			add_node = true,
			place_node = true,
			add_node_level = true,
			liquid_transformed = true,
		},
		getnode = true,
		function(pos, node)
			if node.name == "nc_terrain:dirt_with_grass" then return end
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			node = minetest.get_node(above)
			if allsedges[node.name] then return minetest.remove_node(above) end
		end
	})

minetest.register_abm({
		label = "sedge growth/death",
		interval = 2,
		chance = 250,
		arealoaded = 1,
		nodenames = {"group:flora_sedges"},
		action = function(pos, node)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			local bnode = minetest.get_node_or_nil(below)
			if not bnode then return end
			if bnode.name ~= grassname
			or not nodecore.can_grass_grow_under(pos) then
				return minetest.remove_node(pos)
			end

			if #nodecore.find_nodes_around(pos, "group:moist", {2, 1, 2}) < 1
			then return end

			local lv = allsedges[node.name]
			local grow = lv and allsedges[lv + 1]
			if grow then
				nodecore.set_loud(pos, {name = grow, param2 = 2})
				return nodecore.witness(pos, "sedge growth")
			end
		end
	})

nodecore.register_on_peat_compost(function(pos)
		if math_random(1, 10) ~= 1 then return end

		if minetest.get_node(pos).name ~= grassname then return end

		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if not (nodecore.air_equivalent(above)
			and nodecore.can_grass_grow_under(above)
			and #nodecore.find_nodes_around(above, "group:moist", {2, 1, 2}) > 0)
		then return end

		nodecore.set_loud(above, {name = modname .. ":sedge_1", param2 = 2})
	end)
