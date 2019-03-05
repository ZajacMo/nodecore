-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local alldirs = {
	e = {x = 1, y = 0, z = 0},
	w = {x = -1, y = 0, z = 0},
	u = {x = 0, y = 1, z = 0},
	d = {x = 0, y = -1, z = 0},
	n = {x = 0, y = 0, z = 1},
	s = {x = 0, y = 0, z = -1}
}

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
	t.r = vector.scale(t.l, -1)
	t.b = vector.scale(t.t, -1)
	t.k = vector.scale(t.f, -1)
end

function nodecore.node_spin(pos, node, clicker, itemstack, pointed_thing)
	node = node or minetest.get_node(pos)
	node.param2 = node.param2 + 1
	if node.param2 >= 24 then node.param2 = node.param2 - 24 end
	minetest.swap_node(pos, node)
	return itemstack
end

local optic_queue = {}

function nodecore.optic_check(pos)
	optic_queue[minetest.hash_node_position(pos)] = pos
end

nodecore.register_limited_abm({
		label = "Optic Check",
		interval = 1,
		chance = 1,
		limited_max = 100,
		limited_alert = 100,
		nodenames = {"group:optic_check"},
		action = nodecore.optic_check
	})

local function scan(pos, dir)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	for i = 1, 16 do
		p = vector.add(p, dir)
		local node = minetest.get_node(p)
		if p.name == "ignore" then return end
		if p.name ~= "air" then return p, node end
	end
end

function nodecore.optic_emit(pos, dir)
	local hit, node = scan(pos, dir)
	-- XXX: LEFT OFF HERE
end

local function optic_process(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def and def.optic_check then return def.optic_check(pos, node, def) end
	for _, dir in pairs(alldirs) do
		local p, node = scan(pos, dir)
		if node then
			local def = minetest.registered_items[node.name] or {}
			if def.optic_check then nodecore.optic_check(p) end
		end
	end		
end

minetest.register_globalstep(function()
		-- snapshot batch, as processing may write to queue
		local batch = optic_queue
		optic_queue = {}
		for _, pos in pairs(batch) do
			optic_process(pos)
		end
	end)
