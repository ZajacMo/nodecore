-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local minproto = 39
local minrelease = "5.2"

local rejected = {}

minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		local pinfo = minetest.get_player_information(pname)
		if (not pinfo) or (pinfo.protocol_version < minproto) then
			rejected[pname] = true
			minetest.kick_player(pname, "Outdated client, "
				.. minrelease .. " required")
			return minetest.after(0, function()
					return minetest.chat_send_all("*** " .. pname
						.. " rejected. (protocol version "
						.. (pinfo and pinfo.protocol_version or "unknown") .. ")")
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
