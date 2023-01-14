-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local cheatmsg = nodecore.translate("CHEATS ENABLED")

local interact_cheats = {
	fly = true,
	teleport = true,
	pulverize = true,
	noclip = true,
	fast = true,
	ncdqd = true,
	keepinv = true
}

local always_cheats = {
	bring = true,
	give = true,
	["debug"] = true,
	basic_debug = true
}

for k in pairs(always_cheats) do interact_cheats[k] = true end

local cheatitems = nodecore.group_expand("group:cheat", true)
local function ischeating(player)
	local cheating = false
	local pname = player:get_player_name()
	local privs = minetest.get_player_privs(pname)
	if privs.interact then
		cheating = cheating or not nodecore.player_can_take_damage(player)
		cheating = cheating or not nodecore.player_visible(player)
		for k in pairs(interact_cheats) do cheating = cheating or privs[k] end
	else
		for k in pairs(always_cheats) do cheating = cheating or privs[k] end
	end
	if not cheating then
		local pinfo = minetest.get_player_information(pname)
		if pinfo and pinfo.protocol_version < 40 then
			cheating = true -- basic_debug not honored
		end
	end
	if not cheating then
		for _, list in pairs(player:get_inventory():get_lists()) do
			for _, stack in pairs(list) do
				if cheatitems[stack:get_name()] then
					cheating = true
					break
				end
			end
			if cheating then break end
		end
	end
	return cheating
end

minetest.register_chatcommand("uncheat", {
		description = "Turns off cheat privs",
		privs = {privs = true},
		func = function(name)
			local privs = minetest.get_player_privs(name)
			local qty = 0
			for k in pairs(interact_cheats) do
				if privs[k] then qty = qty + 1 end
				privs[k] = nil
			end
			minetest.set_player_privs(name, privs)

			local player = minetest.get_player_by_name(name)
			if player then
				local inv = player:get_inventory()
				for lname, list in pairs(inv:get_lists()) do
					for slot, stack in pairs(list) do
						if cheatitems[stack:get_name()] then
							inv:set_stack(lname, slot, "")
							qty = qty + stack:get_count()
						end
					end
				end
			end

			minetest.chat_send_player(name,
				qty > 0 and ("Removed " .. qty .. " cheat(s)")
				or "No active cheats found")

			if player and ischeating(player) then
				minetest.chat_send_player(name, "Unable to remove"
					.. " all cheats; may be caused by 3rd party mods,"
					.. " player admin status, settings (e.g."
					.. " enable_damage), or outdated software")
			end
		end
	})

local function privcheck(player)
	nodecore.hud_set(player, {
			label = "cheats",
			group = {},
			hud_elem_type = "text",
			position = {x = 0.5, y = 1},
			text = ischeating(player) and cheatmsg or "",
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
