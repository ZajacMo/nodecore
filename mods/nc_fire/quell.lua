-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()

if nodecore.fire_quell == nil then
	nodecore.fire_quell = modstore:get_int("quell") == 1
end

minetest.register_chatcommand("quell", {
		description = "toggle fire quelling",
		privs = {server = true},
		params = "[on|off]",
		func = function(_, param)
			if param and param ~= "" then
				if param:lower() == "on" then
					nodecore.fire_quell = true
				elseif param:lower() == "off" then
					nodecore.fire_quell = false
				else
					return false, "/quell param not recognized"
				end
			else
				nodecore.fire_quell = not nodecore.fire_quell
			end
			modstore:set_int("quell", nodecore.fire_quell and 1 or 0)
			return true, "Fire is now " .. (nodecore.fire_quell and "QUELLED" or "NORMAL")
		end
	})
