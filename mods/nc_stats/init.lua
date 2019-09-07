-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, os, pairs, table, type, vector
    = math, minetest, nodecore, os, pairs, table, type, vector
local math_random, os_date, table_remove
    = math.random, os.date, table.remove
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()
local modstore = minetest.get_mod_storage()

------------------------------------------------------------------------
-- DATABASE SETUP

local statsdb = {}
nodecore.statsdb = statsdb

local function load_check(s)
	s = s and s ~= "" and minetest.deserialize(s)
	return type(s) == "table" and s or {}
end
do
	local s = load_check(modstore:get_string(modname))
	statsdb[false] = s
	s.firstseen = s.firstseen or os_date("!*t")
	s.startup = (s.startup or 0) + 1
end

local function dbadd_nav(qty, dirty, db, root, key, ...)
	local v = db[root]
	if key then
		if not v or type(v) ~= "table" then
			v = {}
			db[root] = v
		end
		if dirty then v.dirty = true end
		return dbadd_nav(qty, nil, v, key, ...)
	else
		v = v and type(v) == "number" and v or 0
		db[root] = v + qty
	end
end
local function dbadd(qty, root, ...)
	if qty == 0 then return end
	return dbadd_nav(qty, true, statsdb, root, ...)
end

local function playeradd(qty, player, ...)
	if not player then return end
	local pname = (type(player) == "string") and player or player:get_player_name()
	if not pname then return end
	local data = statsdb[pname]
	if not data then
		data = load_check(player:get_meta():get_string(modname))
		statsdb[pname] = data
	end
	dbadd(qty, pname, ...)
	if not statsdb[pname].firstseen then
		statsdb[pname].firstseen = os_date("!*t")
	end
	dbadd(qty, false, "players", ...)
end
nodecore.player_stat_add = playeradd

------------------------------------------------------------------------
-- PLAYER EVENTS

local function reghook(func, stat, pwhom, npos)
	return func(function(...)
			local t = {...}
			local whom = t[pwhom]
			local n = npos and t[npos].name or nil
			return playeradd(1, whom, stat, n)
		end)
end
reghook(minetest.register_on_punchnode, "punch", 3, 2)
reghook(minetest.register_on_dignode, "dig", 3, 2)
reghook(minetest.register_on_placenode, "place", 3, 2)
reghook(minetest.register_on_dieplayer, "die", 1)
reghook(minetest.register_on_respawnplayer, "spawn", 1)
reghook(minetest.register_on_joinplayer, "join", 1)
reghook(minetest.register_on_leaveplayer, "leave", 1)

local function unpackreason(reason)
	if type(reason) ~= "table" then return reason or "?" end
	if reason.from then return reason.from, reason.type or nil end
	return reason.type or "?"
end

minetest.register_on_player_hpchange(function(whom, change, reason)
		if change < 0 then
			return playeradd(-change, whom, "hurt", unpackreason(reason))
		else
			return playeradd(change, whom, "heal", unpackreason(reason))
		end
	end)

minetest.register_on_cheat(function(player, reason)
		playeradd(1, player, "cheat", unpackreason(reason))
	end)

minetest.register_on_chat_message(function(name, msg)
		dbadd(1, name, "chat", (msg:sub(1, 1) == "/") and "command" or "message")
	end)

minetest.register_on_shutdown(function()
		for _, player in pairs(minetest.get_connected_players()) do
			playeradd(1, player, "shutdown")
		end
	end)

------------------------------------------------------------------------
-- PLAYER INVENTORY SCAN

local function invscan(dt, player)
	local inv = player:get_inventory()
	local t = {}
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not stack:is_empty() then
			t[stack:get_name()] = true
		end
	end
	for k in pairs(t) do
		playeradd(dt, player, "inv", k)
	end
end

------------------------------------------------------------------------
-- PLAYER MOVEMENT/IDLE HOOKS

local playdb = { }
local idlemin = 5
local function movement(dt, player)
	if not player or not player:is_player() then return end
	local pn = player:get_player_name()

	local pd = playdb[pn]
	if not pd then
		pd = {}
		playdb[pn] = pd
	end

	local pos = player:get_pos()
	local dir = player:get_look_dir()
	local cur = { pos.x, pos.y, pos.z, dir.x, dir.y, dir.z }
	local moved
	if pd.last then
		for i = 1, 6 do
			moved = moved or pd.last[i] ~= cur[i]
		end
		if moved then
			playeradd(vector.distance(pos,
					{x = pd.last[1], y = pd.last[2], z = pd.last[3]}),
				player, "distance")
		end
	end
	pd.last = cur

	local t = pd.t or 0
	if moved then
		pd.t = 0
		if t >= idlemin then
			playeradd(t, player, "idle")
			return playeradd(dt, player, "move")
		else
			return playeradd(t + dt, player, "move")
		end
	else
		if t >= idlemin then
			return playeradd(dt, player, "idle")
		else
			pd.t = t + dt
			if (t + dt) >= idlemin then
				return playeradd(t + dt, player, "idle")
			end
		end
	end
end
minetest.register_globalstep(function(dt)
		for _, player in pairs(minetest.get_connected_players()) do
			invscan(dt, player)
			movement(dt, player)
		end
	end)

------------------------------------------------------------------------
-- DATABASE FLUSH CYCLE

local opq = {}

local function flushkey(k)
	local v = statsdb[k]
	if not v or not v.dirty then return end
	v.dirty = nil

	v.datafix = v.datafix or 0
	if v.datafix < 1 then
		v.datafix = 1

		local q = k and v or v.players
		for _, n in pairs({"hurt", "heal", "cheat"}) do
			local old = q[n]
			if old then
				q[n] = {}
				for xk, xv in pairs(old) do
					if type(xv) == "number" then
						dbadd_nav(xv, nil, q[n], unpackreason(xk))
					else
						q[n][xk] = xv
					end
				end
			end
		end
	end

	if k == false then
		return modstore:set_string(modname, minetest.serialize(v))
	end

	local player = minetest.get_player_by_name(k)
	if player then
		return player:get_meta():set_string(modname, minetest.serialize(v))
	end
end

local function flushop()
	local k = table_remove(opq)
	if k == nil then return end
	minetest.after(0, flushop)
	return flushkey(k)
end

local function flushenq()
	minetest.after(20, flushenq)
	if #opq > 0 then return end
	for k in pairs(statsdb) do
		opq[#opq + 1] = k
	end
	for i = 1, #opq do
		local j = math_random(1, #opq)
		opq[i], opq[j] = opq[j], opq[i]
	end
	minetest.after(0, flushop)
end
flushenq()

minetest.register_globalstep(function(dt)
		dbadd(dt, false, "elapsed")
		dbadd(1, false, "tick")
	end)

minetest.register_on_leaveplayer(function(player)
		return flushkey(player:get_player_name())
	end)
minetest.register_on_shutdown(function()
		dbadd(1, false, "shutdown")
		flushkey(false)
		for _, player in pairs(minetest.get_connected_players()) do
			flushkey(player:get_player_name())
		end
	end)
