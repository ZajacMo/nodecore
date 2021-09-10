-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string
    = math, minetest, nodecore, string
local math_abs, string_format
    = math.abs, string.format
-- LUALOCALS > ---------------------------------------------------------

local fixedtime = 0.2

local warncount = 0
local nextwarn = 0
local function warn(curtime)
	warncount = warncount + 1
	if nextwarn > 0 then return end
	nodecore.log("warning", string_format(
			"had to manually adjust time of day (e.g. %1.4f -> %1.4f)"
			.. " %d time(s), which creates extra network traffic for all clients"
			.. "; make sure time_speed = 0 (currently %d)",
			curtime, fixedtime, warncount, minetest.settings:get("time_speed") or 72))
	nextwarn = 300
	warncount = 0
end

local timer = 0
minetest.register_globalstep(function(dtime)
		nextwarn = nextwarn - dtime
		timer = timer - dtime
		if timer > 0 then return end
		timer = 4
		local curtime = minetest.get_timeofday()
		if math_abs(curtime - fixedtime) > 0.001 then
			warn(curtime)
			minetest.set_timeofday(fixedtime)
		end
	end)

minetest.unregister_chatcommand("time")
