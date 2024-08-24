-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string, type
    = minetest, nodecore, string, type
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local minproto = 43
local minrelease = "5.8"

local rejected = {}

function nodecore.player_rejected(player)
	local pname = type(player) == "string" and player
	or player:get_player_name()
	return rejected[pname]
end

local kickmsg = string_format("\n\n%s\n%s",
	nodecore.translate("Your Minetest version is outdated, please update!"),
	nodecore.translate("Version @1 or higher is required.", minrelease))

local announcetext = "@1 rejected. (protocol version @2)"
nodecore.translate_inform(announcetext)

local announce = nodecore.setting_bool(
	minetest.get_current_modname() .. "_client_version_announce",
	false,
	"Announce players kicked due to client version",
	[[Players with outdated client versions cannot be rejected by game/mod
	code before allowing them to join, so we have to allow them to join, and
	then kick them. We suppress the normal join/leave messages to cut down
	on noise. Enabling this option produces a single short announcement
	about player rejections, as these "partial" joins may have privacy
	implications.]]
)

minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		local pinfo = minetest.get_player_information(pname)
		if (not pinfo) or (pinfo.protocol_version < minproto) then
			rejected[pname] = true
			minetest.kick_player(pname, kickmsg)
			return announce and minetest.after(0, function()
					return minetest.chat_send_all("*** "
						.. nodecore.translate(announcetext, pname,
							pinfo and pinfo.protocol_version or "unknown"))
				end)
		else
			rejected[pname] = nil
		end
	end)

local oldjoined = minetest.send_join_message
function minetest.send_join_message(pname, ...)
	local pinfo = minetest.get_player_information(pname)
	if pinfo.protocol_version < minproto then return end
	return oldjoined(pname, ...)
end

local oldleft = minetest.send_leave_message
function minetest.send_leave_message(pname, ...)
	if rejected[pname] then return end
	return oldleft(pname, ...)
end
