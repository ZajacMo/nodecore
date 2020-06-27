-- LUALOCALS < ---------------------------------------------------------
-- SKIP: include nodecore
local dofile, error, minetest, pairs, rawget, rawset, setmetatable,
      table, tostring, type
    = dofile, error, minetest, pairs, rawget, rawset, setmetatable,
      table, tostring, type
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
nodecore.version = include("version")

local function callguard(n, t, k, v)
	if type(v) ~= "function" then return v end
	return function(first, ...)
		if first == t then
			error("called " .. n .. ":" .. k .. "() instead of " .. n .. "." .. k .. "()")
		end
		return v(first, ...)
	end
end
for k, v in pairs(minetest) do
	minetest[k] = callguard("minetest", minetest, k, v)
end
setmetatable(nodecore, {
		__newindex = function(t, k, v)
			rawset(nodecore, k, callguard("nodecore", t, k, v))
		end
	})

minetest.register_on_mods_loaded(function()
		for _, n in pairs(minetest.get_modnames()) do
			if n == "default" then
				error(nodecore.product
					.. " cannot be loaded on top of another game!")
				error()
			end
		end
	end)

local levels = {none = true, error = true, warning = true, action = true, info = true, verbose = true}
function nodecore.log(level, ...)
	if not level or not levels[level] then error("invalid log level " .. tostring(level)) end
	return minetest.log(level, ...)
end

minetest.after(0, function()
		local reg = "registered_"
		local t = {}
		for k, v in pairs(nodecore) do
			if k:sub(1, #reg) == reg and type(v) == "table" and #v > 0 then
				t[#t + 1] = k .. ": " .. #v
			end
		end
		table_sort(t)
		for _, x in pairs(t) do nodecore.log("warning", x) end
	end)

include("compat_vector")
include("issue9043")

include("util_misc")
include("util_hookmeta")
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
include("match")

include("fx_digparticles")

include("register_mods")
include("register_entlabels")

include("mapgen_limits")
include("mapgen_shared")

include("item_on_register")
include("item_drop_in_place")
include("item_oldnames")
include("item_tool_break")
include("item_tool_sounds")
include("item_punch_sounds")
include("item_sound_pitch")
include("item_nodebox_zfighting")
include("item_virtual")
include("item_stackmax")
include("item_touch_hurt")
include("item_txp_overlay")
include("item_tiledump")
