-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string
    = minetest, nodecore, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local shapeparams = {0, 0, 0, 2, 4}

local colors = {
	{name = "Pink", color = "e040c0"},
	{name = "Red", color = "ff0000"},
	{name = "Orange", color = "ff8000"},
	{name = "Yellow", color = "ffff00"},
	{name = "White", color = "e0e0e0"},
	{name = "Cyan", color = "00c0c0"},
	{name = "Blue", color = "0000ff"},
	{name = "Violet", color = "8000ff"},
	{name = "Black", color = "202020"},
}
local function flowername(shapeid, colorid)
	return string_format("%s:flower%d%d", modname, shapeid, colorid)
end

for shapeid = 1, 5 do
	for colorid = 1, #colors do
		local txr = modname .. "_flower_" .. shapeid .. "_top.png^[multiply:#"
		.. colors[colorid].color .. "^" .. modname .. "_flower_" .. shapeid
		.. "_base.png"
		minetest.register_node(flowername(shapeid, colorid),
			{
				description = colors[colorid].name .. " Flower",
				drawtype = 'plantlike',
				waving = 1,
				tiles = {txr},
				wield_image = txr,
				inventory_image = txr,
				sunlight_propagates = true,
				paramtype = 'light',
				walkable = false,
				paramtype2 = "meshoptions",
				place_param2 = shapeparams[shapeid],
				groups = {
					snappy = 1,
					flower = 1,
					flammable = 1,
					attached_node = 1
				},
				nc_flower_shape = shapeid,
				nc_flower_color = colorid,
				sounds = nodecore.sounds("nc_terrain_swishy"),
				selection_box = {
					type = "fixed",
					fixed = {-6/16, -0.5, -6/16, 6/16, 4/16, 6/16},
				},
			})
	end
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
			param2 = shapeparams[shapeid],
		})
end
reggen(1, 2, 0.002)
reggen(2, 3, 0.02)
reggen(3, 4, 0.2)
reggen(4, 5, 0.02)
reggen(5, 6, 0.002)
