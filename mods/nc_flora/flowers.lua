-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, string
    = ipairs, math, minetest, nodecore, string
local math_floor, math_random, string_format
    = math.floor, math.random, string.format
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
	{name = "Pink", color = "e040c0"},
	{name = "Red", color = "ff0000"},
	{name = "Orange", color = "ff8000"},
	{name = "Yellow", color = "ffff00"},
	{name = "White", color = "e0e0e0"},
	{name = "Azure", color = "0080c0"},
	{name = "Blue", color = "0000ff"},
	{name = "Violet", color = "8000ff"},
	{name = "Black", color = "202020"},
}
local function flowername(shapeid, colorid)
	return string_format("%s:flower_%d_%d", modname, shapeid, colorid)
end

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
				paramtype2 = "meshoptions",
				place_param2 = shape.param2,
				groups = {
					snappy = 1,
					living_flower = 1,
					flammable = 1,
					attached_node = 1
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
		})
end

local function reggen(shapeid, colorid, rare)
	return minetest.register_decoration({
			name = flowername(shapeid, colorid),
			deco_type = "simple",
			place_on = {"nc_terrain:dirt_with_grass"},
			sidelen = 1,
			noise_params = {
				offset = -0.001 + 0.001 * rare,
				scale = 0.001,
				spread = {x = 100, y = 100, z = 100},
				seed = 1572,
				octaves = 3,
				persist = 0.7
			},
			decoration = flowername(shapeid, colorid),
			param2 = shapes[shapeid].param2,
		})
end
reggen(1, 2, 0.002)
reggen(2, 3, 0.02)
reggen(3, 4, 0.2)
reggen(4, 5, 0.02)
reggen(5, 6, 0.002)

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

nodecore.register_limited_abm({
		label = "flowers wilting/growing",
		interval = 1,
		chance = 100,
		nodenames = {"group:living_flower"},
		action = function(pos, node)
			local soil = flowerable(pos)
			if soil == false then
				local wilt = minetest.registered_items[node.name].flower_wilts_to
				if not wilt then return end
				return nodecore.set_loud(pos, {name = wilt})
			end
			if (not soil) or (math_random(1, 5) > soil)
			or #nodecore.find_nodes_around(pos, "group:moist", 2) < 1
			then return end

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
			v_shape = (v_shape / weight) ^ 0.5 / 2 + 0.01
			v_color = (v_color / weight) ^ 0.5 / 2 + 0.01
			local newshape = math_floor(nodecore.boxmuller() * v_shape + m_shape + 0.5)
			local newcolor = math_floor(nodecore.boxmuller() * v_color + m_color + 0.5)
			nodecore.log("warning", string_format("flower at %s: m_shape %f, v_shape %f, shape %d; "
					.. "m_color %f, v_color %f, color %d", minetest.pos_to_string(grow),
					m_shape, v_shape, newshape, m_color, v_color, newcolor))
			if newcolor < 1 or newcolor > #colors or newshape < 1 or newshape > #shapes then return end

			nodecore.set_loud(grow, {
					name = flowername(newshape, newcolor),
					param2 = shapes[newshape].param2
				})
		end
	})
