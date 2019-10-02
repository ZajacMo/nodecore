-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local root = {
	".....",
	".....",
	"..r..",
	".....",
	".....",
}
local trunk = {
	".....",
	".....",
	"..t..",
	".....",
	".....",
}
local bot = {
	".....",
	".ebe.",
	".btb.",
	".ebe.",
	".....",
}
local low = {
	".lll.",
	"lebel",
	"lbtbl",
	"lebel",
	".lll.",
}
local hi = {
	".lll.",
	"llell",
	"lebel",
	"llell",
	".lll.",
}
local top = {
	".....",
	".lll.",
	".lll.",
	".lll.",
	".....",
}

nodecore.tree_schematic = nodecore.ezschematic(
	{
		["."] = {name = "air", prob = 0},
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
