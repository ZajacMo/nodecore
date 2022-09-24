-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local function player_name(player)
	if not player then return end
	if type(player) == "string" then return player end
	player = player.get_player_name and player:get_player_name()
	if type(player) == "string" then return player end
end

local dirty
local priv_cache = {}

minetest.register_globalstep(function()
		if dirty then

			priv_cache = {}

			dirty = false
		end
	end)

function nodecore.get_player_privs_cached(player)
	player = player_name(player)
	if not player then return {} end
	local cached = priv_cache[player]
	if cached then return cached end
	cached = minetest.get_player_privs(player)
	priv_cache[player] = cached
	dirty = true
	return cached
end

local oldset = minetest.set_player_privs
function minetest.set_player_privs(player, ...)
	local function helper(...)
		local name = player_name(player)
		if name then priv_cache[name] = nil end
		return ...
	end
	return helper(oldset(player, ...))
end

function nodecore.interact(player)
	return nodecore.get_player_privs_cached(player).interact
end
