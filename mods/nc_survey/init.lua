-- LUALOCALS < ---------------------------------------------------------
local dofile, loadfile, minetest, nodecore
    = dofile, loadfile, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

nodecore.surveydata = {}

dofile(path .. "/gather.lua")

local http = minetest.request_http_api()
loadfile(path .. "/report.lua")(http)
