-- LUALOCALS < ---------------------------------------------------------
local core, pairs
    = core, pairs
-- LUALOCALS > ---------------------------------------------------------

core.register_privilege("pulverize", {
		description = "Can pulverize inventory items",
		give_to_singleplayer = false,
		give_to_admin = false
	})

local wrap = {pulverize = true, clearinv = true}
for k, v in pairs(core.registered_chatcommands) do
	if wrap[k] then
		v.privs = v.privs or {}
		v.privs.pulverize = true
		core.override_chatcommand(k, v)
	end
end
