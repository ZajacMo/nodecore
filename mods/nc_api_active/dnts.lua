-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, next, nodecore, pairs, string, vector
    = error, math, minetest, next, nodecore, pairs, string, vector
local math_floor, string_format
    = math.floor, string.format
-- LUALOCALS > ---------------------------------------------------------

-- Active Block Modifiers, meet Delayed Node Triggers.

-- Definition:
--- name: "modname:technicalname"
--- nodenames: {"mod:itemname", "group:name"}
--- time: float (optional),
--- loop: boolean,
--- action: function(pos, node) end

local hash = minetest.hash_node_position
local deepcopy = nodecore.deepcopy
local mismatch = nodecore.prop_mismatch
local serialize = minetest.serialize
local deserialize = minetest.deserialize
local dntkey = "dntdata"
local datacache = {}

local function data_load(pos)
	pos = vector.round(pos)
	local cachekey = hash(pos)
	local found = datacache[cachekey]
	if found then return found end
	local s = minetest.get_meta(pos):get_string(dntkey)
	found = {
		key = cachekey,
		pos = pos,
		sched = s and deserialize(s) or {}
	}
	found.orig = deepcopy(found.sched)
	datacache[cachekey] = found
	return found
end

local function data_save(data)
	if not mismatch(data.sched, data.orig, true) then return end

	local ser = next(data.sched) and serialize(data.sched) or ""
	minetest.get_meta(data.pos):set_string(dntkey, ser)

	data.orig = deepcopy(data.sched)
end

nodecore.registered_dnts = {}

local function dnt_timer(data)
	local now = nodecore.gametime
	local nexttime
	for _, v in pairs(data.sched) do
		if (not nexttime) or (v < nexttime) then nexttime = v end
	end

	if not nexttime then return end
	if data.timer and (data.timer > now) and (nexttime > data.timer)
	and (nexttime < data.timer + 1) then return end

	local delay = nexttime - now
	if delay < 0.001 then delay = 0.001 end
	minetest.get_node_timer(data.pos):start(delay)

	data.timer = nexttime
	data_save(data)
end

local function dnt_execute(pos, data)
	data = data or data_load(pos)

	local now = nodecore.gametime
	local registered = nodecore.registered_dnts
	local runnable = {}
	local sched = data.sched
	local dirty
	for dntname, schedtime in pairs(sched) do
		local def = registered[dntname]
		if not def then
			sched[dntname] = nil
			dirty = true
		elseif schedtime <= now and (def.ignore_stasis or not nodecore.stasis) then
			runnable[def] = true
			local newtime = def.loop and (now + def.time) or nil
			sched[dntname] = newtime
			dirty = true
		end
	end

	local node = minetest.get_node(pos)
	local nn = node.name
	for k in pairs(runnable) do
		local idx = k.nodeidx
		if (not idx) or idx[nn] then
			k.action(pos, node)
			if minetest.get_node(pos).name ~= nn then break end
		end
	end

	if dirty then data_save(data) end
	dnt_timer(data)
end

-- local squelched = {}
-- local function maybecheck(data)
-- local s = squelched[data.key]
-- if s and s > nodecore.gametime then return end
-- squelched[data.key] = nodecore.gametime + 5 + math_random() * 10
-- return dnt_execute(data.pos, data)
-- end

function nodecore.dnt_set(pos, name, time)
	local data = data_load(pos)
	local prev = data.sched[name]
	time = nodecore.gametime + (time or nodecore.registered_dnts[name].time or 1)
	if prev and prev <= time then return end
	data.sched[name] = time
	data_save(data)
	dnt_timer(data)
end

function nodecore.dnt_reset(pos, name, time)
	local data = data_load(pos)
	local prev = data.sched[name]
	time = nodecore.gametime + (time or nodecore.registered_dnts[name].time or 1)
	if prev and prev == time then return end
	data.sched[name] = time
	data_save(data)
	dnt_timer(data)
end

minetest.nodedef_default.on_timer = function(pos)
	return dnt_execute(pos)
end

nodecore.register_on_register_item(function(_, def)
		if def.on_timer then
			return error("on_timer hook is disallowed in "
				.. nodecore.product .. "; use DNT instead")
		end
	end)

local autostarts = {}
local function dntregen(pos, node)
	local start = autostarts[node.name]
	if start then
		for def in pairs(start) do
			nodecore.dnt_set(pos, def.name)
		end
	end
end
nodecore.register_on_nodeupdate(dntregen)

function nodecore.register_dnt(def)
	if not def.name then return error("dnt name required") end
	if not def.action then return error("dnt action required") end
	if nodecore.registered_dnts[def.name] then
		return error(string_format("dnt %q already registered", def.name))
	end
	def.nodeidx = nodecore.group_expand(def.nodenames, true)
	if def.autostart then
		nodecore.group_expand(def.nodenames, function(name)
				local set = autostarts[name]
				if not set then
					set = {}
					autostarts[name] = set
				end
				set[def] = true
			end)
		local abmtime = math_floor(def.time or 1)
		if abmtime < 1 then abmtime = 1 end
		minetest.register_abm({
				label = "dnt regen: " .. def.name,
				interval = abmtime,
				chance = 1,
				nodenames = def.nodenames,
				action = dntregen
			})
	end
	nodecore.registered_dnts[def.name] = def
end
