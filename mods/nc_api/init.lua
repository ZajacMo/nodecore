-- LUALOCALS < ---------------------------------------------------------
-- SKIP: include nodecore
local dofile, error, ipairs, minetest, pairs, rawget, rawset, table,
      tostring, type
    = dofile, error, ipairs, minetest, pairs, rawget, rawset, table,
      tostring, type
local table_concat, table_insert, table_sort
    = table.concat, table.insert, table.sort
-- LUALOCALS > ---------------------------------------------------------

local nodecore = rawget(_G, "nodecore") or {}
rawset(_G, "nodecore", nodecore)

local include = rawget(_G, "include") or function(...)
	local parts = {...}
	table_insert(parts, 1, minetest.get_modpath(minetest.get_current_modname()))
	if parts[#parts]:sub(-4) ~= ".lua" then
		parts[#parts] = parts[#parts] .. ".lua"
	end
	return dofile(table_concat(parts, "/"))
end
rawset(_G, "include", include)

nodecore.product = "NodeCore"
nodecore.version, nodecore.releasedate = include("version")

local levels = {none = true, error = true, warning = true, action = true, info = true, verbose = true}
function nodecore.log(level, ...)
	if not level or not levels[level] then error("invalid log level " .. tostring(level)) end
	return minetest.log(level, ...)
end

nodecore.log("info", nodecore.product .. (nodecore.version and (" Version " .. nodecore.version)
		or " DEVELOPMENT VERSION"))

do
	local ticked = 0
	local function regreport()
		ticked = ticked + 1
		if ticked < 5 then return minetest.after(0, regreport) end
		local reg = "registered_"
		local raw = "_raw"
		local t = {}
		for k, v in pairs(nodecore) do
			if k:sub(1, #reg) == reg and k:sub(-#raw) ~= raw
			and type(v) == "table" then
				local qty = 0
				for _ in pairs(v) do qty = qty + 1 end
				t[#t + 1] = "#" .. k .. " = " .. qty
			end
		end
		table_sort(t)
		for _, x in ipairs(t) do nodecore.log("info", x) end
	end
	minetest.after(0, regreport)
end

for k, v in pairs(minetest) do nodecore[k .. "_raw"] = v end

include("hotfix_authcache")
include("hotfix_fixhack")
include("hotfix_teleportfix")

include("compat_creative")
include("compat_issue10127")
include("compat_legacyent")

include("util_settings")
include("util_privs")
include("util_misc")
include("util_spin")
include("util_falling")
include("util_scan_flood")
include("util_node_is")
include("util_toolcaps")
include("util_stack")
include("util_phealth")
include("util_facedir")
include("util_sound")
include("util_translate")
include("util_ezschematic")
include("util_gametime")
include("util_settlescan")
include("util_texturemod")
include("util_spawn")
include("match")

include("fx_digparticles")

include("register_mods")
include("register_entlabels")
include("register_backfaces")
include("register_nodeupdate")

include("mapgen_limits")
include("mapgen_shared")

include("item_on_register")
include("item_diggable")
include("item_drop_in_place")
include("item_dig_drops")
include("item_oldnames")
include("item_tool_break")
include("item_tool_sounds")
include("item_tool_rakes")
include("item_punch_sounds")
include("item_sound_pitch")
include("item_nodebox_zfighting")
include("item_virtual")
include("item_stackmax")
include("item_liquid_stack")
include("item_touch_hurt")
include("item_support_falling")
include("item_dig_destroy")
include("item_mapcolors")

include("item_groupdump")
include("item_tiledump")

include("setup_serverversion")
include("setup_clientversion")
