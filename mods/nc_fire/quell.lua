-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modstore = core.get_mod_storage()

if nc.fire_quell == nil then
	nc.fire_quell = modstore:get_int("quell") == 1
end

core.register_chatcommand("quell", {
		description = "toggle fire quelling",
		privs = {server = true},
		params = "[on|off]",
		func = function(_, param)
			if param and param ~= "" then
				if param:lower() == "on" then
					nc.fire_quell = true
				elseif param:lower() == "off" then
					nc.fire_quell = false
				else
					return false, "/quell param not recognized"
				end
			else
				nc.fire_quell = not nc.fire_quell
			end
			modstore:set_int("quell", nc.fire_quell and 1 or 0)
			return true, "Fire is now " .. (nc.fire_quell and "QUELLED" or "NORMAL")
		end
	})
