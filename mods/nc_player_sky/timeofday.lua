-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.settings:set("time_speed", 0)

minetest.after(0, function()
		minetest.set_timeofday(5/24)
	end)

minetest.unregister_chatcommand("time")
