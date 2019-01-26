-- LUALOCALS < ---------------------------------------------------------
local SecureRandom, math, minetest, nodecore, os, pairs
    = SecureRandom, math, minetest, nodecore, os, pairs
local math_random, os_clock
    = math.random, os.clock
-- LUALOCALS > ---------------------------------------------------------

local store = minetest.get_mod_storage()
nodecore.surveydata.store = store

------------------------------------------------------------------------
-- World-level stats

local worldid = store:get_string("worldid")
if not worldid or #worldid ~= 40 then
	local rand = SecureRandom()
	rand = rand and rand:next_bytes(16)
	rand = rand or math_random()
	worldid = minetest.sha1(rand)
	store:set_string("worldid", worldid)
end

local function worldadd(stat, qty)
	return store:set_float(stat, (store:get_float(stat) or 0) + 1)
end
worldadd("startups", 1)
minetest.register_on_shutdown(function() return worldadd("shutdowns", 1) end)

------------------------------------------------------------------------
-- Player-level stats

local players = store:get_string("players")
players = players and minetest.deserialize(players) or {}
nodecore.surveydata.players = players

local function statadd(pn, stat, qty)
	if not pn then return end
	local p = players[pn] or {}
	players[pn] = p
	p[stat] = (p[stat] or 0) + qty
end

local function getpn(whom)
	if not whom then return end
	local pn = whom.get_player_name
	if not pn then return end
	pn = pn(whom)
	if not pn or not pn:find("%S") then return end
	if pn ~= "singleplayer" then return minetest.sha1(pn) end
	return pn
end

local function reghook(func, stat)
	return func(function(whom)
			return statadd(getpn(whom), stat, 1)
		end)
end
reghook(minetest.register_on_dieplayer,	    "die")
reghook(minetest.register_on_respawnplayer, "spawn")
reghook(minetest.register_on_joinplayer,    "join")
reghook(minetest.register_on_leaveplayer,   "leave")

minetest.register_on_player_hpchange(function(whom, change)
		if change < 0 then
			return statadd(getpn(whom), "hurt", -change)
		else
			return statadd(getpn(whom), "heal", change)
		end
	end)

------------------------------------------------------------------------
-- Update timer

local playdb = { }
local idlemin = 5
local function procstep(dt, player)
	local pn = getpn(player)
	if not pn then return end
	local pd = playdb[pn] or {}
	playdb[pn] = pd

	local pos = player:getpos()
	local dir = player:get_look_dir()
	local cur = { pos.x, pos.y, pos.z, dir.x, dir.y, dir.z }
	local moved
	if pd.last then
		for i = 1, 6 do
			moved = moved or pd.last[i] ~= cur[i]
		end
	end
	pd.last = cur

	local t = pd.t or 0
	if moved then
		pd.t = 0
		if t >= idlemin then
			statadd(pn, "idle", t)
			return statadd(pn, "move", dt)
		else
			return statadd(pn, "move", t + dt)
		end
	else
		if t >= idlemin then
			return statadd(pn, "idle", dt)
		else
			pd.t = t + dt
			if (t + dt) >= idlemin then
				return statadd(pn, "idle", t + dt)
			end
		end
	end
end

local clockstart = os_clock()
local timestart = minetest.get_us_time()
local function timer()
	minetest.after(10, timer)

	local now = minetest.get_us_time()
	local dt = (now - timestart) / 1000 / 1000
	timestart = now

	local clock = os_clock()
	local dc = clock - clockstart
	clockstart = clock

	worldadd("uptime", dt)
	worldadd("paused", dc - dt)
	for _, player in pairs(minetest.get_connected_players()) do
		procstep(dt, player)
	end
	store:set_string("players", minetest.serialize(players))
end
timer()
minetest.register_on_shutdown(timer)
