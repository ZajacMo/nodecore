-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, string, type, vector
    = getmetatable, minetest, nodecore, string, type, vector
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local keepname = "keepinv"

minetest.register_privilege(keepname, {
		description = "Allow player to keep inventory on teleport",
		give_to_singleplayer = false,
		give_to_admin = false
	})

local function patchplayers()
	local anyplayer = (minetest.get_connected_players())[1]
	if not anyplayer then
		return minetest.after(0, patchplayers)
	end

	local meta = getmetatable(anyplayer)
	meta = meta and meta.__index or meta
	if not meta.set_pos then return end

	local setraw = meta.set_pos
	function meta:set_pos(pos, ...)
		if (not self) or (not self.is_player) or (not self:is_player())
		or (not pos) or type(pos) ~= "table" or pos.keepinv
		or minetest.check_player_privs(self, keepname) then
			return setraw(self, pos, ...)
		end
		local old = self:get_pos()
		if old and vector.distance(pos, old) > 16 then
			nodecore.log("action", string_format("%s teleporting from %s to %s",
					self:get_player_name(), minetest.pos_to_string(old, 0),
					minetest.pos_to_string(pos, 0)))
			nodecore.inventory_dump(self)
		end
		return setraw(self, pos, ...)
	end
	nodecore.log("action", modname .. " player:set_pos hooked")
end
minetest.after(0, patchplayers)
