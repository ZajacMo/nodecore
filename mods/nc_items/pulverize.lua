-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs
    = minetest, pairs
-- LUALOCALS > ---------------------------------------------------------

minetest.register_privilege("pulverize", {
		description = "Can use the /pulverize command",
		give_to_singleplayer = false,
		give_to_admin = false
	})

for k, v in pairs(minetest.registered_chatcommands) do
	if k == "pulverize" then
		v.privs = v.privs or {}
		v.privs.pulverize = true
		minetest.override_chatcommand(k, v)
	end
end
