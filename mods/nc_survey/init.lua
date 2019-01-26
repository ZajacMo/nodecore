-- LUALOCALS < ---------------------------------------------------------
local dofile, minetest, nodecore
    = dofile, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

nodecore.surveydata = {}

dofile(path .. "/gather.lua")
--dofile(path .. "/report.lua")
