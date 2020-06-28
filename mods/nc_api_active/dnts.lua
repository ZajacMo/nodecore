-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, string
    = error, minetest, nodecore, pairs, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

-- Active Block Modifiers, meet Delayed Node Triggers.

-- Definition:
--- mname: "modname:technicalname"
--- nodenames: {"mod:itemname", "group:name"}
--- time: float (optional),
--- loop: boolean,
--- action: function(pos, node) end

nodecore.registered_dnts = {}

local grouppref = "group:"
local function buildidx(list)
	if not list then return end
	local n = {}
	local g
	for _, v in pairs(list) do
		if v:sub(1, #grouppref) == grouppref then
			g = g or {}
			g[v:sub(#grouppref + 1)] = true
		else
			n[v] = true
		end
	end
	if g then
		minetest.after(0, function()
				for k in pairs(minetest.registered_nodes) do
					for x in pairs(g) do
						if minetest.get_item_group(k, x) > 0 then
							n[k] = true
						end
					end
				end
			end)
	end
	return n
end

function nodecore.register_dnt(def)
	if not def.name then return error("dnt name required") end
	if not def.action then return error("dnt action required") end
	if nodecore.registered_dnts[def.name] then
		return error(string_format("dnt %q already registered", def.name))
	end
	def.nodeidx = buildidx(def.nodenames)
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
	for k, v in pairs(data) do
		if k then
			v = v - el
			if v < 0 then
				local def = reg[k]
				if def then
					if def.ignore_stasis or not nodecore.stasis then
						run[def] = true
						v = def.loop and def.time or nil
					else
						v = def.time and (def.time < 1) and def.time or 1
					end
					data[k] = v
					if (not min) or (min < v) then min = v end
				end
			else
				data[k] = v
				if (not min) or (min < v) then min = v end
			end
		end
	end
	data[false] = now

	meta:set_string(dntkey, minetest.serialize(data))
	if min then minetest.get_node_timer(pos):start(min) end

	local node = minetest.get_node(pos)
	local nn = node.name
	for k in pairs(run) do
		local idx = k.nodeidx
		if (not idx) or idx[nn] then k.action(pos, node) end
	end
end

local function dntload(pos)
	local meta = minetest.get_meta(pos)
	local s = meta:get_string(dntkey)
	s = s and s ~= "" and minetest.deserialize(s) or {}
	return s, function() return dntsave(pos, meta, s) end
end

function nodecore.dnt_set(pos, name, time)
	local data, save = dntload(pos)
	local prev = data[name]
	time = time or nodecore.registered_dnts[name].time or 1
	if prev and prev < time then return end
	data[name] = time
	return save()
end

minetest.nodedef_default.on_timer = function(pos)
	local _, save = dntload(pos)
	return save()
end

nodecore.register_on_register_item(function(def)
		if def.on_timer then
			return error("on_timer hook is disallowed in "
				.. nodecore.product .. "; use DNT instead")
		end
	end)
