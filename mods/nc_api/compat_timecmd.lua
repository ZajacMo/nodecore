-- LUALOCALS < ---------------------------------------------------------
local core, math, string, table
    = core, math, string, table
local math_floor, string_format, table_concat
    = math.floor, string.format, table.concat
-- LUALOCALS > ---------------------------------------------------------

local function timecore()
	local sec = core.get_gametime()
	local min = math_floor(sec / 60)
	sec = sec - min * 60
	local hr = math_floor(min / 60)
	min = min - hr * 60
	local day = math_floor(hr / 24)
	hr = hr - day * 24
	local parts = {}
	if day > 0 then
		parts[#parts + 1] = string_format("%d day%s", day, day == 1 and "" or "s")
	end
	if hr > 0 then
		parts[#parts + 1] = string_format("%d hour%s", hr, hr == 1 and "" or "s")
	end
	if min > 0 then
		parts[#parts + 1] = string_format("%d minute%s", min, min == 1 and "" or "s")
	end
	if sec > 0 then
		parts[#parts + 1] = string_format("%d second%s", sec, sec == 1 and "" or "s")
	end
	return true, string_format("This world is %s old", table_concat(parts, ", "))
end

local function timecmd(n)
	return core.override_chatcommand(n, {
			params = "",
			descrption = "Show world age",
			func = timecore
		})
end

timecmd("time")
timecmd("days")
