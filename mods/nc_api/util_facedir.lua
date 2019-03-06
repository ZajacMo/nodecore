-- LUALOCALS < ---------------------------------------------------------
local ipairs, nodecore, pairs, vector
    = ipairs, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local alldirs = {}
for k, v in pairs(nodecore.dirs()) do
	alldirs[v.n] = v
end

local facedirs = {
	{"u", "w"},
	{"u", "n"},
	{"u", "e"},
	{"n", "u"},
	{"n", "w"},
	{"n", "d"},
	{"n", "e"},
	{"s", "d"},
	{"s", "w"},
	{"s", "u"},
	{"s", "e"},
	{"e", "s"},
	{"e", "u"},
	{"e", "n"},
	{"e", "d"},
	{"w", "s"},
	{"w", "d"},
	{"w", "n"},
	{"w", "u"},
	{"d", "s"},
	{"d", "e"},
	{"d", "n"},
	{"d", "w"},
	[0] = {"u", "s"}
}

local function cross(a, b)
	return {
		x = a.y * b.z - a.z * b.y,
		y = a.z * b.x - a.x * b.z,
		z = a.x * b.y - a.y * b.x
	}
end

for _, t in ipairs(facedirs) do
	t.t = alldirs[t[1]]
	t.f = alldirs[t[2]]
	t[2] = nil
	t[1] = nil
	t.l = cross(t.t, t.f)
	t.r = vector.multiply(t.l, -1)
	t.b = vector.multiply(t.t, -1)
	t.k = vector.multiply(t.f, -1)
end

nodecore.facedirs = facedirs
