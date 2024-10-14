-- LUALOCALS < ---------------------------------------------------------
local core, nc, string, type
    = core, nc, string, type
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local minproto = 43
local minrelease = "5.8"

local rejected = {}

function nc.player_rejected(player)
	local pname = type(player) == "string" and player
	or player:get_player_name()
	return rejected[pname]
end

local kickmsg = string_format("\n\n%s\n%s",
	nc.translate("Your Minetest version is outdated, please update!"),
	nc.translate("Version @1 or higher is required.", minrelease))

local announcetext = "@1 rejected. (protocol version @2)"
nc.translate_inform(announcetext)

local announce = nc.setting_bool(
	core.get_current_modname() .. "_client_version_announce",
	false,
	"Announce players kicked due to client version",
	[[Players with outdated client versions cannot be rejected by game/mod
	code before allowing them to join, so we have to allow them to join, and
	then kick them. We suppress the normal join/leave messages to cut down
	on noise. Enabling this option produces a single short announcement
	about player rejections, as these "partial" joins may have privacy
	implications.]]
)

core.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		local pinfo = core.get_player_information(pname)
		if (not pinfo) or (pinfo.protocol_version < minproto) then
			rejected[pname] = true
			core.kick_player(pname, kickmsg)
			return announce and core.after(0, function()
					return core.chat_send_all("*** "
						.. nc.translate(announcetext, pname,
							pinfo and pinfo.protocol_version or "unknown"))
				end)
		else
			rejected[pname] = nil
		end
	end)

local oldjoined = core.send_join_message
function core.send_join_message(pname, ...)
	local pinfo = core.get_player_information(pname)
	if pinfo.protocol_version < minproto then return end
	return oldjoined(pname, ...)
end

local oldleft = core.send_leave_message
function core.send_leave_message(pname, ...)
	if rejected[pname] then return end
	return oldleft(pname, ...)
end
