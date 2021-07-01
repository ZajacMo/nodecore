-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string
    = minetest, nodecore, string
local string_format
    = string.format
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
					flower = 1,
					flammable = 1,
					attached_node = 1
				},
				nc_flower_shape = shapeid,
				nc_flower_color = colorid,
				wilts_to = flowername(shapeid, 0),
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
				flower = 1,
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
