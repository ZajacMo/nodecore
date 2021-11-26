-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, string
    = ipairs, math, minetest, nodecore, pairs, string
local math_abs, math_random, string_format
    = math.abs, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local shapes = {
	{name = "Bell", size = 1/4},
	{name = "Cup", size = 1/4},
	{name = "Rosette", size = 1/4},
	{name = "Cluster", param2 = 2, size = 3/8},
	{name = "Star", param2 = 4, size = 3/8},
}

local colors = {
	{name = "Pink", color = "d23379"},
	{name = "Red", color = "d80000"},
	{name = "Orange", color = "c16100"},
	{name = "Yellow", color = "baba00"},
	{name = "White", color = "adadad"},
	{name = "Azure", color = "39849b"},
	{name = "Blue", color = "2424fe"},
	{name = "Violet", color = "5900b2"},
	{name = "Black", color = "202020"},
}

local function flowername(shapeid, colorid)
	return string_format("%s:flower_%d_%d", modname, shapeid, colorid)
end

local mapgenrates = {
	[flowername(1, 2)] = {shape = 1, rate = 0.002},
	[flowername(2, 3)] = {shape = 2, rate = 0.01},
	[flowername(3, 4)] = {shape = 3, rate = 0.1},
	[flowername(4, 5)] = {shape = 4, rate = 0.01},
	[flowername(5, 6)] = {shape = 5, rate = 0.001},
}

for shapeid = 1, #shapes do
	local shape = shapes[shapeid]
	for colorid = 1, #colors do
		local color = colors[colorid]
		local txr = string_format("%s_flower_color.png^(nc_terrain_grass_top.png"
			.. "^[mask:%s_grass_mask.png)^[mask:%s_flower_%d_base.png"
			.. "^(%s_flower_%d_top.png^[multiply:#%s)", modname, modname,
			modname, shapeid, modname, shapeid, color.color)
		minetest.register_node(flowername(shapeid, colorid),
			{
				description = color.name .. " " .. shape.name .. " Flower",
				drawtype = 'plantlike',
				waving = 1,
				tiles = {txr},
				wield_image = txr,
				inventory_image = txr,
				sunlight_propagates = true,
				paramtype = 'light',
				walkable = false,
				floodable = true,
				paramtype2 = "meshoptions",
				place_param2 = shape.param2,
				groups = {
					snappy = 1,
					flower_living = 1,
					flammable = 1,
					attached_node = 1,
					flower_mutant = (not mapgenrates[flowername(shapeid,
							colorid)]) and 1 or nil
				},
				nc_flower_shape = shapeid,
				nc_flower_color = colorid,
				flower_wilts_to = flowername(shapeid, 0),
				sounds = nodecore.sounds("nc_terrain_swishy"),
				selection_box = {
					type = "fixed",
					fixed = {-shape.size, -0.5, -shape.size,
						shape.size, 4/16, shape.size},
				},
			})
	end
	local dry = string_format("%s_flower_color_dry.png^(nc_terrain_grass_top.png"
		.. "^[mask:%s_grass_mask.png)^[mask:%s_flower_%d_base.png"
		.. "^(%s_flower_%d_top.png^[multiply:#7b7a64)", modname, modname,
		modname, shapeid, modname, shapeid)
	minetest.register_node(flowername(shapeid, 0),
		{
			description = "Wilted " .. shape.name .. " Flower",
			drawtype = 'plantlike',
			waving = 1,
			tiles = {dry},
			wield_image = dry,
			inventory_image = dry,
			sunlight_propagates = true,
			paramtype = 'light',
			walkable = false,
			floodable = true,
			paramtype2 = "meshoptions",
			place_param2 = shape.param2,
			groups = {
				snappy = 1,
				flower_wilted = 1,
				flammable = 1,
				attached_node = 1,
				flora_dry = 1
			},
			sounds = nodecore.sounds("nc_terrain_swishy"),
			selection_box = {
				type = "fixed",
				fixed = {-shape.size, -0.5, -shape.size,
					shape.size, 4/16, shape.size},
			},
			drop = "",
			destroy_on_dig = 100
		})
end

for k, v in pairs(mapgenrates) do
	minetest.register_decoration({
			name = k,
			deco_type = "simple",
			place_on = {"nc_terrain:dirt_with_grass"},
			sidelen = 1,
			noise_params = {
				offset = -0.001 + 0.005 * v.rate,
				scale = 0.001,
				spread = {x = 100, y = 100, z = 100},
				seed = 1572,
				octaves = 3,
				persist = 0.7
			},
			decoration = k,
			param2 = shapes[v.shape].param2,
		})
end

local function flowerable(pos)
	local grass = nodecore.grassable(pos)
	if not grass then return grass end
	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	local bnode = minetest.get_node_or_nil(below)
	if not bnode then return end
	local soil = minetest.get_item_group(bnode.name, "soil")
	if soil < 1 then return false end
	return soil
end

local function getvariation(basenode, peers, key, max, mutate)
	local basedef = minetest.registered_items[basenode.name]
	local baseval = basedef and basedef[key]
	if not baseval then return end
	local maxdiff = 0
	local up
	local down
	for _, p in ipairs(peers) do
		local def = minetest.registered_items[minetest.get_node(p).name]
		local val = def and def[key]
		if val then
			local diff = math_abs(val - baseval)
			if diff > maxdiff then maxdiff = diff end
			if val == baseval + 1 then up = true end
			if val == baseval - 1 then down = true end
		end
	end
	if math_random(1, 200) < (maxdiff * maxdiff) then return end
	if baseval > 1 then
		local downchance = (down and 0.1 or 0) + (up and 0.05 or 0) + 0.01
		if math_random() < downchance * mutate then return baseval - 1 end
	end
	if baseval < max then
		local upchance = (up and 0.05 or 0) + (down and 0.02 or 0) + 0.002
		if math_random() < upchance * mutate then return baseval + 1 end
	end
	return baseval
end

minetest.register_abm({
		label = "flowers wilting/growing",
		interval = 1,
		chance = 100,
		nodenames = {"group:flower_living"},
		action = function(pos, node)
			local function die()
				local wilt = minetest.registered_items[node.name].flower_wilts_to
				if not wilt then return end
				return nodecore.set_loud(pos, {name = wilt})
			end

			local soil = flowerable(pos)
			if soil == false then return die() end
			if (not soil) or (math_random(1, 5) > soil)
			or #nodecore.find_nodes_around(pos, "group:moist", 2) < 1
			then return end

			local rads = 0
			for _, p in ipairs(nodecore.find_nodes_around(pos, "group:lux_emit", 2)) do
				rads = rads + minetest.get_item_group(minetest.get_node(p).name, "lux_emit")
			end
			if math_random(1, 100) < rads then return die() end

			local grow = {
				x = pos.x + math_random(-2, 2),
				y = pos.y + math_random(-1, 1),
				z = pos.z + math_random(-2, 2)
			}
			if not (nodecore.buildable_to(grow) and flowerable(grow)) then return end

			local mutate = 1 + rads * rads / 20
			local peers = nodecore.find_nodes_around(grow, "group:flower_living", {2, 1, 2})
			local shape = getvariation(node, peers, "nc_flower_shape", #shapes, mutate)
			if not shape then return die() end
			local color = getvariation(node, peers, "nc_flower_color", #colors, mutate)
			if not color then return die() end

			nodecore.set_loud(grow, {
					name = flowername(shape, color),
					param2 = shapes[shape].param2
				})
			return nodecore.witness(grow, "flower spread")
		end
	})

nodecore.register_aism({
		label = "flower stack wilt",
		interval = 1,
		chance = 50,
		itemnames = {"group:flower_living"},
		action = function(stack, data)
			if data.toteslot then return end
			local shapeid = minetest.registered_items[stack:get_name()].nc_flower_shape
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
			taken:set_name(flowername(shapeid, 0))
			if data.inv then taken = data.inv:add_item("main", taken) end
			if not taken:is_empty() then nodecore.item_eject(data.pos, taken) end
			return stack
		end
	})
