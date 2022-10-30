-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, os
    = minetest, nodecore, os
local os_time
    = os.time
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local modstore = minetest.get_mod_storage()

local updated = "NodeCore updated from @1 to @2"
nodecore.translate_inform(updated)

local verkey = modname .. "_version"
local updkey = modname .. "_updated"

local function vercomp(meta)
	local newver = nodecore.version or "?"
	local oldver = meta:get_string(verkey)
	if oldver == "" then
		meta:set_string(verkey, newver)
		return
	end
	oldver = oldver ~= "" and oldver or "?"
	if newver == oldver then return end
	meta:set_string(verkey, newver)
	meta:set_int(updkey, os_time())
	return nodecore.translate(updated, oldver, newver)
end

-- Announce in public chat (for chat bridges)
local function announce(depth)
	if depth > 0 then
		return minetest.after(0, function()
				return announce(depth - 1)
			end)
	end
	local text = vercomp(modstore)
	if not text then return end
	nodecore.log("warning", text)
	return minetest.chat_send_all(text)
end
announce(5)

-- Notify players on connect
minetest.register_on_joinplayer(function(player)
		local text = vercomp(player:get_meta())
		if not text then return end
		return minetest.chat_send_player(player:get_player_name(), text)
	end)
