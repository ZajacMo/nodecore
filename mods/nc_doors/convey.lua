-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, vector
    = ipairs, math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local hashpos = minetest.pos_to_string
local is_falling = {groups = {falling_node = true}}

local queue = {}
local queued = {}

local vector_add = vector.add
local function addkeep(a, b)
	local t = vector_add(a, b)
	for k, v in pairs(b) do
		if t[k] == nil then
			t[k] = v
		end
	end
	return t
end

function nodecore.door_push(pos, ...)
	local key = hashpos(pos)
	if queued[key] then return end
	local node = minetest.get_node(pos)
	if not nodecore.match(node, is_falling) then return end
	node.param = nil
	local try = {}
	for i, dir in ipairs({...}) do
		try[i] = addkeep(pos, dir)
	end
	queue[#queue + 1] = {
		key = key,
		from = pos,
		try = try,
		attempts = math_random(10, 20)
	}
	queued[key] = true
end

local function tryprocess(item, retry)
	local node = minetest.get_node(item.from)
	if not nodecore.match(node, is_falling) then return end
	for _, t in ipairs(item.try) do
		if nodecore.buildable_to(t) then
			local meta = minetest.get_meta(item.from):to_table()
			minetest.remove_node(item.from)
			nodecore.fallcheck({x = item.from.x, y = item.from.y + 1, z = item.from.z})
			nodecore.set_loud(t, node)
			meta.fields = meta.fields or {}
			meta.fields.tweenfrom = meta.fields.tweenfrom
			or minetest.serialize(item.from)
			minetest.get_meta(t):from_table(meta)
			nodecore.visinv_update_ents(t)
			if t.after then
				nodecore.door_push(t, t.after)
			else
				nodecore.fallcheck(t)
			end
			local re = retry[hashpos(item.from)]
			if not re then return end
			for _, r in ipairs(re) do
				if r.attempts and r.attempts > 0 and not queued[r.key] then
					r.attempts = r.attempts - 1
					queue[#queue + 1] = r
					queued[r.key] = true
				end
			end
			return
		end
	end
	for _, t in ipairs(item.try) do
		local key = hashpos(t)
		local r = retry[key]
		if not r then
			r = {}
			retry[key] = r
		end
		r[#r + 1] = item
	end
end

minetest.register_globalstep(function()
		local retry = {}
		local i = 1
		while i <= #queue do
			local item = queue[i]
			queued[hashpos(item.from)] = nil
			tryprocess(item, retry)
			i = i + 1
		end
		queue = {}
		queued = {}
	end)
