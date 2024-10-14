-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, pairs, vector
    = core, ipairs, math, nc, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local hashpos = core.pos_to_string
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

function nc.door_push(pos, ...)
	local key = hashpos(pos)
	if queued[key] then return end
	local node = core.get_node(pos)
	if not nc.match(node, is_falling) then return end
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
	local node = core.get_node(item.from)
	if not nc.match(node, is_falling) then return end
	for _, t in ipairs(item.try) do
		if nc.buildable_to(t) then
			local meta = core.get_meta(item.from):to_table()
			core.remove_node(item.from)
			nc.fallcheck({x = item.from.x, y = item.from.y + 1, z = item.from.z})
			nc.set_loud(t, node)
			core.get_meta(t):from_table(meta)
			nc.visinv_tween_from(t, item.from)
			nc.visinv_update_ents(t)
			if t.after then
				nc.door_push(t, t.after)
			else
				nc.fallcheck(t)
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

core.register_globalstep(function()
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
