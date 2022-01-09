-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

minetest.register_globalstep(function() minetest.set_timeofday(0.2) end)

minetest.unregister_chatcommand("time")
