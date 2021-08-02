-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()

if nodecore.stasis == nil then
	nodecore.stasis = modstore:get_int("stasis") == 1
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
			modstore:set_int("stasis", nodecore.stasis and 1 or 0)
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

local oldcheck = minetest.check_single_for_falling
function minetest.check_single_for_falling(...)
	if nodecore.stasis then return end
	return oldcheck(...)
end
