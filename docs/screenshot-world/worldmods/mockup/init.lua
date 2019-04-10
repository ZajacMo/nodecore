-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.settings:set("time_speed", 0)
minetest.after(0, function() minetest.set_timeofday(0.5) end)

local function setup(p)
	local n = p:get_player_name()

	local v = minetest.get_player_privs(n)
	v.fly = true
	v.fast = true
	v.give = true
	v.interact = true
	v.nc_reative = true
	minetest.set_player_privs(n, v)

	p:set_pos({x = -113, y = 5, z = -93})
end
minetest.register_on_joinplayer(setup)
minetest.register_on_respawnplayer(setup)
