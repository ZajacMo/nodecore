-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore, type, vector
    = getmetatable, minetest, nodecore, type, vector
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
			nodecore.inventory_dump(self)
		end
		return setraw(self, pos, ...)
	end
	nodecore.log("action", modname .. " player:get_inventory hooked")
end
minetest.after(0, patchplayers)
