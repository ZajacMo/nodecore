-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modstore = core.get_mod_storage()

if nc.stasis == nil then
	nc.stasis = modstore:get_int("stasis") == 1
end

core.register_chatcommand("stasis", {
		description = "toggle world stasis",
		privs = {server = true},
		params = "[on|off]",
		func = function(_, param)
			if param and param ~= "" then
				if param:lower() == "on" then
					nc.stasis = true
				elseif param:lower() == "off" then
					nc.stasis = false
				else
					return false, "/stasis param not recognized"
				end
			else
				nc.stasis = not nc.stasis
			end
			modstore:set_int("stasis", nc.stasis and 1 or 0)
			return true, "World is now " .. (nc.stasis and "FROZEN" or "ACTIVE")
		end
	})

local abm = core.register_abm
function core.register_abm(def, ...)
	if not def.ignore_stasis then
		local act = def.action
		def.action = function(...)
			if nc.stasis then return end
			return act(...)
		end
	end
	return abm(def, ...)
end

local oldcheck = core.check_single_for_falling
function core.check_single_for_falling(...)
	if nc.stasis then return end
	return oldcheck(...)
end
