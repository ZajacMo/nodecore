-- LUALOCALS < ---------------------------------------------------------
local math, string, tonumber
    = math, string, tonumber
local math_floor, string_match
    = math.floor, string.match
-- LUALOCALS > ---------------------------------------------------------

local stamp = tonumber("$Format:%at$")
if not stamp then return end
stamp = math_floor((stamp - 1540612800) / 60)
stamp = ("00000000" .. stamp):sub(-8)

local date = "$FORMAT:%as$";
date = string_match(date, "^%d%d%d%d-%d%d-%d%d$") and date or nil

return stamp .. "-$Format:%h$", date
