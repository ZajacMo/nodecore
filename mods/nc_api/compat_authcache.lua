-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, type
    = minetest, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function player_name(player)
	if not player then return end
	if type(player) == "string" then return player end
	player = player.get_player_name and player:get_player_name()
	if type(player) == "string" then return player end
end

local priv_cache = {}

local function invalidateafter(method)
	local oldfunc = minetest[method]
	minetest[method] = function(player, ...)
		local function helper(...)
			local name = player_name(player)
			if name then priv_cache[name] = nil end
			return ...
		end
		return helper(oldfunc(player, ...))
	end
end
invalidateafter("set_player_privs")
invalidateafter("remove_player_auth")

local function invalidateon(event)
	minetest["register_on_" .. event](function(player)
			local name = player_name(player)
			if name then priv_cache[name] = nil end
		end)
end
invalidateon("joinplayer")
invalidateon("leaveplayer")

local oldreload = minetest.auth_reload
function minetest.auth_reload(...)
	priv_cache = {}
	return oldreload(...)
end

local function clone(tbl)
	local t = {}
	for k, v in pairs(tbl) do t[k] = v end
	return t
end

local oldget = minetest.get_player_privs
function minetest.get_player_privs(player)
	local pname = player_name(player)
	if not pname then return oldget(player) end
	local cached = priv_cache[pname]
	if cached then return clone(cached) end
	cached = oldget(pname)
	priv_cache[pname] = cached
	return clone(cached)
end
