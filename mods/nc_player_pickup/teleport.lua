-- LUALOCALS < ---------------------------------------------------------
local core, getmetatable, nc, string, type, vector
    = core, getmetatable, nc, string, type, vector
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local keepname = "keepinv"

core.register_privilege(keepname, {
		description = "Allow player to keep inventory on teleport",
		give_to_singleplayer = false,
		give_to_admin = false
	})

local function patchplayers()
	local anyplayer = (core.get_connected_players())[1]
	if not anyplayer then
		return core.after(0, patchplayers)
	end

	local meta = getmetatable(anyplayer)
	meta = meta and meta.__index or meta
	if not meta.set_pos then return end

	local setraw = meta.set_pos
	function meta:set_pos(pos, ...)
		if (not self) or (not self.is_player) or (not self:is_player())
		or (not pos) or type(pos) ~= "table" or pos.keepinv
		or core.get_player_privs(self)[keepname] then
			return setraw(self, pos, ...)
		end
		local old = self:get_pos()
		if old and vector.distance(pos, old) > 16 then
			nc.log("action", string_format("%s teleports from %s to %s",
					self:get_player_name(), core.pos_to_string(old, 0),
					core.pos_to_string(pos, 0)))
			nc.inventory_dump(self)
		end
		return setraw(self, pos, ...)
	end
	nc.log("info", modname .. " player:set_pos hooked")
end
core.after(0, patchplayers)
