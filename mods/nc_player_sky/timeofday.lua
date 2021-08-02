-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string
    = math, minetest, nodecore, string
local math_abs, string_format
    = math.abs, string.format
-- LUALOCALS > ---------------------------------------------------------

local fixedtime = 0.2

local timer = 0
minetest.register_globalstep(function(dtime)
		timer = timer - dtime
		if timer > 0 then return end
		timer = 4
		local curtime = minetest.get_timeofday()
		if math_abs(curtime - fixedtime) > 0.001 then
			nodecore.log("warning", string_format(
					"time of day: %1.4f -> %1.4f; make sure time_speed = 0",
					curtime, fixedtime))
			minetest.set_timeofday(fixedtime)
		end
	end)

minetest.unregister_chatcommand("time")
