-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, string
    = error, minetest, nodecore, pairs, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

-- Active Block Modifiers, meet Delayed Node Triggers.

nodecore.registered_dnts = {}

function nodecore.register_dnt(def)
	if not def.name then return error("dnt name required") end
	if not def.name then return error("dnt action required") end
	if nodecore.registered_dnts[def.name] then
		return error(string_format("dnt %q already registered", def.name))
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
	for k, v in pairs(data) do
		if k then
			v = v - el
			if v < 0 then
				run[k] = true
				data[k] = nil
			else
				data[k] = v
				if (not min) or (min < v) then min = v end
			end
		end
	end
	data[false] = now
	meta:set_string(dntkey, minetest.serialize(data))
	if min then minetest.get_node_timer(pos):start(min) end
	local reg = nodecore.registered_dnts
	for k in pairs(run) do reg[k].action(pos) end
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
	if prev and prev < time then return end
	data[name] = time
	return save()
end

function nodecore.dnt_reset(pos, name, time)
	local data, save = dntload(pos)
	local prev = data[name]
	if prev and prev == time then return end
	data[name] = time
	return save()
end

function nodecore.dnt_clear(pos, name)
	local data, save = dntload(pos)
	if not data[name] then return end
	data[name] = nil
	return save()
end

minetest.nodedef_default.on_timer = function(pos)
	local _, save = dntload(pos)
	return save()
end
