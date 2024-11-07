-- LUALOCALS < ---------------------------------------------------------
local core, error, math, nc, next, pairs, string, vector
    = core, error, math, nc, next, pairs, string, vector
local math_floor, string_format, string_gsub
    = math.floor, string.format, string.gsub
-- LUALOCALS > ---------------------------------------------------------

-- Active Block Modifiers, meet Delayed Node Triggers.

-- Definition:
--- name: "modname:technicalname"
--- nodenames: {"mod:itemname", "group:name"}
--- time: float (optional),
--- loop: boolean,
--- action: function(pos, node) end

local hash = core.hash_node_position
local deepcopy = nc.deepcopy
local mismatch = nc.prop_mismatch
local serialize = core.serialize
local deserialize = core.deserialize
local dntkey = "dntdata"
local datacache = {}

local function data_load(pos)
	pos = vector.round(pos)
	local cachekey = hash(pos)
	local found = datacache[cachekey]
	if found then return found end
	local s = core.get_meta(pos):get_string(dntkey)
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
	core.get_meta(data.pos):set_string(dntkey, ser)

	data.orig = deepcopy(data.sched)
end

nc.registered_dnts = {}

local function dnt_timer(data)
	local now = nc.gametime
	local nexttime
	for _, v in pairs(data.sched) do
		if (not nexttime) or (v < nexttime) then nexttime = v end
	end

	if not nexttime then return data_save(data) end
	if data.timer and (data.timer > now) and (nexttime > data.timer)
	and (nexttime < data.timer + 1) then return data_save(data) end

	local delay = nexttime - now
	if delay < 0.001 then delay = 0.001 end
	core.get_node_timer(data.pos):start(delay)

	data.timer = nexttime
	data_save(data)
end

local function dnt_execute(pos)
	local data = data_load(pos)

	data.timer = nil

	local now = nc.gametime
	local registered = nc.registered_dnts
	local runnable = {}
	local sched = data.sched
	for dntname, schedtime in pairs(sched) do
		local def = registered[dntname]
		if not def then
			sched[dntname] = nil
		elseif schedtime <= now and (def.ignore_stasis or not nc.stasis) then
			runnable[def] = true
			local newtime = def.loop and (now + def.time) or nil
			sched[dntname] = newtime
		end
	end

	local node = core.get_node(pos)
	local nn = node.name
	for k in pairs(runnable) do
		local idx = k.nodeidx
		local loaded = k.arealoaded
		if ((not idx) or idx[nn]) and not (loaded
			and nc.near_unloaded(pos, node, loaded)) then
			k.action(pos, node)
			if core.get_node(pos).name ~= nn then break end
		end
	end

	dnt_timer(data)
end

function nc.dnt_get(pos, name)
	local data = data_load(pos)
	local prev = data.sched[name]
	return prev and (prev - nc.gametime)
end

function nc.dnt_set(pos, name, time)
	local data = data_load(pos)
	local prev = data.sched[name]
	local now = nc.gametime
	time = now + (time or nc.registered_dnts[name].time or 1)
	if prev and prev >= now and prev <= time then return end
	data.sched[name] = time
	dnt_timer(data)
end

function nc.dnt_reset(pos, name, time)
	local data = data_load(pos)
	local prev = data.sched[name]
	time = nc.gametime + (time or nc.registered_dnts[name].time or 1)
	if prev and prev == time then return end
	data.sched[name] = time
	dnt_timer(data)
end

core.nodedef_default.on_timer = dnt_execute

nc.register_on_register_item(function(_, def)
		if def.on_timer then
			return error("on_timer hook is disallowed in "
				.. nc.product .. "; use DNT instead")
		end
	end)

local autostarts = {}
local function dntregen(immediate)
	return function(pos, node)
		datacache[hash(pos)] = nil
		local start = autostarts[node.name]
		if start then
			for def in pairs(start) do
				nc.dnt_set(pos, def.name, immediate
					and def.autostart_time or nil)
			end
		end
	end
end
nc.register_on_nodeupdate({
		ignore = {
			stack_set = true,
			remove_node = true,
			dig_node = true,
			add_node_level = true,
			liquid_transformed = true,
		},
		getnode = true,
		func = dntregen(true),
	})

function nc.register_dnt(def)
	local modname = core.get_current_modname()
	if not def.name then return error("dnt name required") end
	if not def.action then return error("dnt action required") end
	if nc.registered_dnts[def.name] then
		return error(string_format("dnt %q already registered", def.name))
	end
	def.nodeidx = def.nodenames and nc.group_expand(def.nodenames, true)
	if def.autostart then
		nc.group_expand(def.nodenames, function(name)
				local set = autostarts[name]
				if not set then
					set = {}
					autostarts[name] = set
				end
				set[def] = true
			end)
		local abmtime = math_floor(def.time or 1)
		if abmtime < 1 then abmtime = 1 end
		local albmlabel = modname .. ":" .. string_gsub(def.name, "%W", "_")
		core.register_abm({
				label = albmlabel,
				interval = abmtime,
				chance = 1,
				nodenames = def.nodenames,
				action = dntregen()
			})
		core.register_lbm({
				name = albmlabel,
				run_at_every_load = true,
				nodenames = def.nodenames,
				action = dntregen(true)
			})
	end
	nc.registered_dnts[def.name] = def
end
