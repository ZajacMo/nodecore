-- LUALOCALS < ---------------------------------------------------------
local core, nc, os
    = core, nc, os
local os_time
    = os.time
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()
local modstore = core.get_mod_storage()

local updated = "NodeCore updated from @1 to @2"
nc.translate_inform(updated)

local verkey = modname .. "_version"
local updkey = modname .. "_updated"

local function vercomp(meta)
	local newver = nc.version or "?"
	local oldver = meta:get_string(verkey)
	if oldver == "" then
		meta:set_string(verkey, newver)
		return
	end
	oldver = oldver ~= "" and oldver or "?"
	if newver == oldver then return end
	meta:set_string(verkey, newver)
	meta:set_int(updkey, os_time())
	return nc.translate(updated, oldver, newver)
end

-- Announce in public chat (for chat bridges)
local function announce(depth)
	if depth > 0 then
		return core.after(0, function()
				return announce(depth - 1)
			end)
	end
	local text = vercomp(modstore)
	if not text then return end
	nc.log("warning", core.get_translated_string(core.settings:get("language") or "", text))
	return core.chat_send_all(text)
end
announce(5)

-- Notify players on connect
core.register_on_joinplayer(function(player)
		local text = vercomp(player:get_meta())
		if not text then return end
		return core.chat_send_player(player:get_player_name(), text)
	end)
