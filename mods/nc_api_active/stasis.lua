-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

if nodecore.stasis == nil then
	nodecore.stasis = minetest.settings:get_bool("nodecore_stasis")
end

minetest.register_chatcommand("stasis", {
		description = "toggle world stasis",
		privs = {server = true},
		params = "[on|off]",
		func = function(_, param)
			if param and param ~= "" then
				if param:lower() == "on" then
					nodecore.stasis = true
				elseif param:lower() == "off" then
					nodecore.stasis = false
				else
					return false, "/stasis param not recognized"
				end
			else
				nodecore.stasis = not nodecore.stasis
			end
			return true, "World is now " .. (nodecore.stasis and "FROZEN" or "ACTIVE")
		end
	})

local abm = minetest.register_abm
function minetest.register_abm(def, ...)
	if not def.ignore_stasis then
		local act = def.action
		def.action = function(...)
			if nodecore.stasis then return end
			return act(...)
		end
	end
	return abm(def, ...)
end
