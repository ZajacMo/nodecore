-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, string, table, tostring, type, vector
    = core, ipairs, nc, pairs, string, table, tostring, type, vector
local string_format, table_concat
    = string.format, table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_on_discover,
nc.registered_on_discovers
= nc.mkreg()

local cache = {}

local function loaddb(p)
	if nc.hints_disabled(p) then return end
	if not (p and nc.interact(p)) then return end
	local player
	local pname
	if type(p) == "string" then
		player, pname = core.get_player_by_name(p), p
	else
		player, pname = p, p:get_player_name()
	end
	if not (player and pname) then return end

	local db = cache[pname]
	if not db then
		local s = player:get_meta():get_string(modname) or ""
		db = s and core.deserialize(s) or {}
		cache[pname] = db
	end

	return db, player, pname, function()
		player:get_meta():set_string(modname, core.serialize(db))
	end

end
nc.get_player_discovered = loaddb

local function discover_deferred(p, keys, prefix)
	local db, player, pname, save = loaddb(p)
	local new = {}
	if not db then return end
	for k in pairs(nc.flatkeys(keys)) do
		k = (prefix or "") .. tostring(k)
		if not db[k] then
			new[#new + 1] = k
		end
	end
	if #new < 1 then return end
	return function()
		for i = 1, #new do db[new[i]] = true end
		core.log("action", string_format("player %s discovers %q", pname,
				table_concat(new, ", ")))
		for _, cb in pairs(nc.registered_on_discovers) do
			cb(player, new, pname, db)
		end
		return save()
	end
end
nc.player_discover_deferred = discover_deferred
local function discover(...)
	local deferred = discover_deferred(...)
	if deferred then return deferred() end
end
nc.player_discover = discover

------------------------------------------------------------------------
-- PLAYER EVENTS

local function reghook(func, stat, pwhom, npos, ppos)
	return func(function(...)
			local t = {...}
			local whom = t[pwhom]
			if not (whom and whom:is_player()) then return end
			local n = npos and t[npos].name or nil
			if ppos then
				local pos = t[ppos]
				local stack = pos and nc.stack_get(pos)
				if stack and not stack:is_empty() then
					discover(whom, stat .. ":" .. stack:get_name())
				end
			end
			return discover(whom, n and (stat .. ":" .. n) or stat)
		end)
end
reghook(nc.register_on_punchnode, "punch", 3, 2, 1)
reghook(nc.register_on_dignode, "dig", 3, 2)
reghook(nc.register_on_placenode, "place", 3, 2)
reghook(nc.register_on_dieplayer, "die", 1)
reghook(nc.register_on_respawnplayer, "spawn", 1)
reghook(nc.register_on_joinplayer, "join", 1)

local function unpackreason(reason)
	if type(reason) ~= "table" then return reason or "?" end
	if reason.nc_type then return "nc", reason.nc_type end
	if reason.from then return reason.from, reason.type or nil end
	return reason.type or "?"
end

nc.register_on_player_hpchange(function(whom, change, reason)
		if change < 0 then
			return discover(whom, "hurt:" .. unpackreason(reason))
		else
			return discover(whom, "heal:" .. unpackreason(reason))
		end
	end)

nc.register_on_cheat(function(player, reason)
		discover(player, "cheat: " .. unpackreason(reason))
	end)

nc.register_on_chat_message(function(name, msg)
		discover(name, "chat:" .. ((msg:sub(1, 1) == "/") and "command" or "message"))
	end)

------------------------------------------------------------------------
-- PLAYER SCAN

nc.register_on_node_stare,
nc.registered_on_node_stares = nc.mkreg()

nc.register_playerstep({
		label = "inv",
		action = function(player, data, dtime)
			-- inventory
			local inv = player:get_inventory()
			local t = {}
			for i = 1, inv:get_size("main") do
				local stack = inv:get_stack("main", i)
				if not stack:is_empty() then
					t[stack:get_name()] = true
				end
			end
			for k in pairs(t) do
				discover(player, "inv:" .. k)
			end

			-- looking at
			local pt = data.raycast()
			if pt and pt.type == "node" and data.staring_pos
			and vector.equals(data.staring_pos, pt.under) then
				data.staring_time = data.staring_time + dtime
				if data.staring_time >= 0.8 then
					data.staring_time = 0
					for _, f in ipairs(nc.registered_on_node_stares) do
						f(player, pt, data)
					end
				end
			else
				data.staring_pos = pt and pt.under
				data.staring_time = dtime
			end
		end
	})

nc.register_on_node_stare(function(player, pt)
		local nn = core.get_node(pt.under).name
		discover(player, "look:" .. nn)
		local stack = nc.stack_get(pt.under)
		if stack and not stack:is_empty() then
			discover(player, "look:" .. stack:get_name())
		end
	end)
