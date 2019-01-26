-- LUALOCALS < ---------------------------------------------------------
local SecureRandom, math, minetest
    = SecureRandom, math, minetest
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local store = minetest.get_mod_storage()

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

local timestart = minetest.get_us_time()
local function timer()
	local now = minetest.get_us_time()
	local duration = (now - timestart) / 1000 / 1000
	timestart = now

	worldadd("uptime", duration)

	store:set_string("players", minetest.serialize(players))

	minetest.after(10, timer)
end
timer()
