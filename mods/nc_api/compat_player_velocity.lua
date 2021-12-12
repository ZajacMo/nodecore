-- LUALOCALS < ---------------------------------------------------------
local getmetatable, minetest, nodecore
    = getmetatable, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hooked
local function joinhook(player)
	if hooked then return end
	hooked = true

	if player:get_velocity() then
		return nodecore.log("info", modname
			.. " player:get_velocity already correct")
	end

	local meta = getmetatable(player)
	meta = meta and meta.__index or meta
	meta.get_velocity = function(self) return self:get_player_velocity() end
	nodecore.log("info", modname .. " player:get_velocity patched")
end
minetest.register_on_joinplayer(joinhook)
