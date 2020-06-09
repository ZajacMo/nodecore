-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string, tonumber
    = math, minetest, nodecore, string, tonumber
local math_floor, string_format
    = math.floor, string.format
-- LUALOCALS > ---------------------------------------------------------

local limit = tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000

local chunksize = tonumber(minetest.get_mapgen_setting("chunksize")) or 5
chunksize = chunksize * 16
local limitchunks = math_floor(limit / chunksize)

nodecore.map_limit_min = (-limitchunks + 0.5) * chunksize + 7.5
nodecore.map_limit_max = (limitchunks - 0.5) * chunksize + 7.5

nodecore.log("info", string_format("mapgen limit: %d, chunk: %d, bounds: %0.1f to %0.1f",
		limit, chunksize, nodecore.map_limit_min, nodecore.map_limit_max))
