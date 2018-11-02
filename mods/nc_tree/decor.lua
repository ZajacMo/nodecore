local minetest = minetest
local modname = minetest.get_current_modname()

local function ezschem(key, yslices, init)
	local size = {}
	local data = {}
	size.y = #yslices
	for y, ys in ipairs(yslices) do
		if size.z and size.z ~= #ys then error("inconsistent z size") end
		size.z = #ys
		for z, zs in ipairs(ys) do
			if size.x and size.x ~= #zs then error("inconsistent x size") end
			size.x = #zs
			for x = 1, zs:len() do
				data[(z - 1) * size.x * size.y + (y - 1) * size.x + x]
				= key[zs:sub(x, x)]
			end
		end
	end
	init = init or {}
	init.size = size
	init.data = data
	return init
end

local root = {
	"     ",
	"     ",
	"  r  ",
	"     ",
	"     ",
}
local trunk = {
	"     ",
	"     ",
	"  t  ",
	"     ",
	"     ",
}
local bot = {
	"     ",
	" lll ",
	" ltl ",
	" lll ",
	"     ",
}
local low = {
	" lll ",
	"lllll",
	"lltll",
	"lllll",
	" lll ",
}
local hi = {
	" lll ",
	"lllll",
	"lllll",
	"lllll",
	" lll ",
}
local top = {
	"     ",
	" lll ",
	" lll ",
	" lll ",
	"     ",
}

minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"nc_terrain:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.008,
			scale = 0.012,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"unknown"},
		y_min = 1,
		y_max = 31000,
		schematic = ezschem(
			{
				[" "] = {name = "air", prob = 0},
				r = {name = modname .. ":root", prob = 255, force_place = true},
				t = {name = modname .. ":tree", prob = 255},
				l = {name = modname .. ":leaves", prob = 255},
			},
			{
				root,
				trunk,
				trunk,
				trunk,
				bot,
				low,
				low,
				hi,
				top
			},
			{
				yslice_prob = {
					{ypos = 1, prob = 255},
					{ypos = 2, prob = 160},
					{ypos = 3, prob = 160},
					{ypos = 4, prob = 160},
					{ypos = 5, prob = 255},
					{ypos = 6, prob = 160},
					{ypos = 7, prob = 160},
					{ypos = 8, prob = 255},
				}
			}
		),
		flags = "place_center_x, place_center_z",
		rotation = "random",
		replacements = {
			["nc_terrain:tree"] = modname .. ":tree",
			["nc_terrain:leaves"] = modname .. ":leaves",
		}
	})