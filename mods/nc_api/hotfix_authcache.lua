-- LUALOCALS < ---------------------------------------------------------
local core, pairs, type
    = core, pairs, type
-- LUALOCALS > ---------------------------------------------------------

if core.features._hotfix_auth_cache then return end
core.features._hotfix_auth_cache = true

local function player_name(player)
	if not player then return end
	if type(player) == "string" then return player end
	player = player.get_player_name and player:get_player_name()
	if type(player) == "string" then return player end
end

local priv_cache = {}

local function invalidateafter(method)
	local oldfunc = core[method]
	core[method] = function(player, ...)
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
	core["register_on_" .. event](function(player)
			local name = player_name(player)
			if name then priv_cache[name] = nil end
		end)
end
invalidateon("joinplayer")
invalidateon("leaveplayer")

local oldreload = core.auth_reload
function core.auth_reload(...)
	priv_cache = {}
	return oldreload(...)
end

local function clone(tbl)
	local t = {}
	for k, v in pairs(tbl) do t[k] = v end
	return t
end

local oldget = core.get_player_privs
function core.get_player_privs(player)
	local pname = player_name(player)
	if not pname then return oldget(player) end
	local cached = priv_cache[pname]
	if cached then return clone(cached) end
	cached = oldget(pname)
	priv_cache[pname] = cached
	return clone(cached)
end
