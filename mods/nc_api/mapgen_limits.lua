-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, tonumber
    = minetest, nodecore, tonumber
-- LUALOCALS > ---------------------------------------------------------

local limit = tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000

local chunksize = tonumber(minetest.get_mapgen_setting("chunksize")) or 5
chunksize = chunksize * 16

nodecore.map_limit_min = (-limit + 0.5) * chunksize + 7.5
nodecore.map_limit_max = (limit - 0.5) * chunksize + 7.5
