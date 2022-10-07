-- LUALOCALS < ---------------------------------------------------------
local minetest, type
    = minetest, type
-- LUALOCALS > ---------------------------------------------------------

local function player_name(player)
	if not player then return end
	if type(player) == "string" then return player end
	player = player.get_player_name and player:get_player_name()
	if type(player) == "string" then return player end
end

local priv_cache = {}

local function invalidateon(method)
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
invalidateon("set_privileges")
invalidateon("remove_player_auth")

local oldreload = minetest.auth_reload
function minetest.auth_reload(...)
	priv_cache = {}
	return oldreload(...)
end

local oldget = minetest.get_player_privs
function minetest.get_player_privs(player)
	player = player_name(player)
	if not player then return {} end
	local cached = priv_cache[player]
	if cached then return cached end
	cached = oldget(player)
	priv_cache[player] = cached
	return cached
end
