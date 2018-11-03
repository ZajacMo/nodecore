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
	return minetest.register_schematic(init)
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
	" ebe ",
	" btb ",
	" ebe ",
	"     ",
}
local low = {
	" lll ",
	"lebel",
	"lbtbl",
	"lebel",
	" lll ",
}
local hi = {
	" lll ",
	"llell",
	"lebel",
	"llell",
	" lll ",
}
local top = {
	"     ",
	" lll ",
	" lll ",
	" lll ",
	"     ",
}

nodecore.tree_schematic = ezschem(
	{
		[" "] = {name = "air", prob = 0},
		r = {name = modname .. ":root", prob = 255, force_place = true},
		t = {name = modname .. ":tree", prob = 255},
		b = {name = modname .. ":leaves", param2 = 2, prob = 255},
		e = {name = modname .. ":leaves", param2 = 1,prob = 255},
		l = {name = modname .. ":leaves", prob = 240},
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
)