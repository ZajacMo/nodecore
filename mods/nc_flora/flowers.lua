-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, string
    = ipairs, math, minetest, nodecore, pairs, string
local math_exp, math_floor, math_random, string_format
    = math.exp, math.floor, math.random, string.format
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
	[flowername(1, 2)] = {shape = 1, rate = 0.001},
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
					living_flower = 1,
					flammable = 1,
					attached_node = 1,
					flower_mutant = mapgenrates[flowername(shapeid,
						colorid)] and 0 or 1
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
				flammable = 1,
				attached_node = 1
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
	if soil == 1 then return end
	return soil - 1
end

local function updatesample(weight, mean, var, value)
	local delta = value - mean
	mean = mean + delta / weight
	local delta2 = value - mean
	var = var + delta * delta2
	return mean, var
end

local function tryrand(mean, stddev, min, max)
	for _ = 1, 5 do
		local value = math_floor(nodecore.boxmuller() * stddev + mean + 0.5)
		if value >= min and value <= max then return value end
	end
end

nodecore.register_limited_abm({
		label = "flowers wilting/growing",
		interval = 1,
		chance = 100,
		nodenames = {"group:living_flower"},
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

			local rads = 1 + #nodecore.find_nodes_around(pos, "group:lux_emit", 2)
			if math_random(1, 100) < rads then return die() end

			local grow = {
				x = pos.x + math_random(-2, 2),
				y = pos.y + math_random(-1, 1),
				z = pos.z + math_random(-2, 2)
			}
			if not (nodecore.buildable_to(grow) and flowerable(grow)) then return end

			local weight = 3
			local m_shape = minetest.registered_items[node.name].nc_flower_shape
			local v_shape = 0
			local m_color = minetest.registered_items[node.name].nc_flower_color
			local v_color = 0
			for _, p in ipairs(nodecore.find_nodes_around(grow, "group:living_flower", 2, 1)) do
				local def = minetest.registered_items[minetest.get_node(p).name]
				if def and def.nc_flower_shape and def.nc_flower_color then
					weight = weight + 1
					m_shape, v_shape = updatesample(weight, m_shape, v_shape, def.nc_flower_shape)
					m_color, v_color = updatesample(weight, m_color, v_color, def.nc_flower_color)
				end
			end
			m_shape = m_shape - 0.2
			m_color = m_color - 0.2
			v_shape = (v_shape / weight) ^ 0.5 * 0.8 + math_exp(rads / 20) + 0.01
			v_color = (v_color / weight) ^ 0.5 * 0.8 + math_exp(rads / 20) + 0.01

			local newshape = tryrand(m_shape, v_shape, 1, #shapes)
			if not newshape then return end
			local newcolor = tryrand(m_color, v_color, 1, #colors)
			if not newcolor then return end

			nodecore.set_loud(grow, {
					name = flowername(newshape, newcolor),
					param2 = shapes[newshape].param2
				})
		end
	})

nodecore.register_aism({
		label = "flower stack wilt",
		interval = 1,
		chance = 50,
		itemnames = {"group:living_flower"},
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
