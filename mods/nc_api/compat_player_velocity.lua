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
	local oldvel = meta.get_velocity
	meta.get_velocity = function(self, ...)
		if self:is_player() then
			return self:get_player_velocity(...)
		else
			return oldvel(self, ...)
		end
	end
	nodecore.log("info", modname .. " player:get_velocity patched")
end
minetest.register_on_joinplayer(joinhook)
