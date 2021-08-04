-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, pairs, string
    = error, math, minetest, nodecore, pairs, string
local math_floor, math_random, string_format
    = math.floor, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

-- Active Block Modifiers, meet Delayed Node Triggers.

-- Definition:
--- name: "modname:technicalname"
--- nodenames: {"mod:itemname", "group:name"}
--- time: float (optional),
--- loop: boolean,
--- action: function(pos, node) end

nodecore.registered_dnts = {}

local autostarts = {}
local function dntregen(pos, node)
	local start = autostarts[node.name]
	if start then
		minetest.log("warning", minetest.pos_to_string(pos) .. " = " .. node.name)
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

local dntkey = "dnt"

local function dntsave(pos, meta, data)
	local now = nodecore.gametime
	local prev = data[false]
	local el = prev and (now - prev) or 0

	local min
	local run = {}
	local reg = nodecore.registered_dnts
	local any
	for k, v in pairs(data) do
		if k then
			v = v - el
			local def = reg[k]
			if not def then
				-- clear deprecated dnts
				data[k] = nil
			else
				if v < 0 then
					if def.ignore_stasis or not nodecore.stasis then
						run[def] = true
						v = def.loop and def.time or nil
					else
						-- auto-defer while on stasis
						v = def.time and (def.time < 1) and def.time or 1
					end
				end
				data[k] = v
				any = any or v
				if v and ((not min) or (min < v)) then min = v end
			end
		end
	end
	data[false] = now

	meta:set_string(dntkey, any and minetest.serialize(data) or "")
	if min then minetest.get_node_timer(pos):start(min) end

	local node = minetest.get_node(pos)
	local nn = node.name
	for k in pairs(run) do
		local idx = k.nodeidx
		if (not idx) or idx[nn] then
			k.action(pos, node)
			if minetest.get_node(pos).name ~= nn then break end
		end
	end
end

local function dntload(pos)
	local meta = minetest.get_meta(pos)
	local s = meta:get_string(dntkey)
	s = s and s ~= "" and minetest.deserialize(s) or {}
	return s, function() return dntsave(pos, meta, s) end
end

local squelched = {}
local function maybecheck(pos, save)
	local hash = minetest.hash_node_position(pos)
	local s = squelched[hash]
	if s and s > nodecore.gametime then return end
	squelched[hash] = nodecore.gametime + 5 + math_random() * 10
	return save()
end

function nodecore.dnt_set(pos, name, time)
	local data, save = dntload(pos)
	local prev = data[name]
	time = time or nodecore.registered_dnts[name].time or 1
	if prev and prev < time then return maybecheck(pos, save) end
	data[name] = time
	return save()
end

function nodecore.dnt_reset(pos, name, time)
	local data, save = dntload(pos)
	local prev = data[name]
	time = time or nodecore.registered_dnts[name].time or 1
	if prev and prev == time then return maybecheck(pos, save) end
	data[name] = time
	return save()
end

minetest.nodedef_default.on_timer = function(pos)
	local _, save = dntload(pos)
	return save()
end

nodecore.register_on_register_item(function(_, def)
		if def.on_timer then
			return error("on_timer hook is disallowed in "
				.. nodecore.product .. "; use DNT instead")
		end
	end)
