-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local cheatmsg = nodecore.translate("CHEATS ENABLED")

local cheats = {
	fly = true,
	bring = true,
	teleport = true,
	pulverize = true,
	noclip = true,
	fast = true,
	ncdqd = true,
	give = true,
	["debug"] = true,
	basic_debug = true,
	keepinv = true
}

local function privcheck(player)
	local cheating = false
	local privs = minetest.get_player_privs(player:get_player_name())
	if privs.interact then
		cheating = cheating or not nodecore.player_can_take_damage(player)
		cheating = cheating or not nodecore.player_visible(player)
		for k in pairs(cheats) do cheating = cheating or privs[k] end
	end
	nodecore.hud_set(player, {
			label = "cheats",
			hud_elem_type = "text",
			position = {x = 0.5, y = 1},
			text = cheating and cheatmsg or "",
			number = 0xFF00C0,
			alignment = {x = 0, y = -1},
			offset = {x = 0, y = -4}
		})
end

local function privcheck_delay(name)
	minetest.after(0, function()
			local player = minetest.get_player_by_name(name)
			return player and privcheck(player)
		end)
end

minetest.register_on_priv_grant(privcheck_delay)
minetest.register_on_priv_revoke(privcheck_delay)
minetest.register_on_joinplayer(function(player)
		return privcheck_delay(player:get_player_name())
	end)

nodecore.interval(2, function()
		for _, player in pairs(minetest.get_connected_players()) do
			privcheck(player)
		end
	end)
