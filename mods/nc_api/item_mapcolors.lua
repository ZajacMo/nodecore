-- LUALOCALS < ---------------------------------------------------------
local io, math, minetest, next, nodecore, pairs, string, table, type
    = io, math, minetest, next, nodecore, pairs, string, table, type
local io_open, math_floor, string_gsub, table_concat, table_sort
    = io.open, math.floor, string.gsub, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local writefile = nodecore.infodump()

local function sortedpairs(tbl)
	local keys = {}
	for k in pairs(tbl) do keys[#keys + 1] = k end
	table_sort(keys)
	local i = 0
	return function()
		i = i + 1
		local k = keys[i]
		if k == nil then return end
		return k, tbl[k]
	end
end

local function clamp(x)
	if type(x) ~= "number" then return end
	x = math_floor(x)
	if x < 0 then return 0 end
	if x > 255 then return 255 end
	return x
end
local function extractcolor(t)
	if type(t) ~= "table" then return end
	local a = clamp(t.a)
	if a == 0 then return 0, 0, 0, 0 end
	local r = clamp(t.r)
	if not r then return end
	local g = clamp(t.g)
	if not g then return end
	local b = clamp(t.b)
	if not b then return end
	return r, g, b, a or 255
end

local function heuristic(v)
	if v.drawtype == "airlike" then
		return 0, 0, 0, 0
	end
	local r, g, b, a = extractcolor(v.post_effect_color)
	if a and a ~= 0 then return r, g, b, a end
end

minetest.after(0, function()
		local missing = {}
		local lines = {}
		local lastmod
		for k, v in sortedpairs(minetest.registered_nodes) do
			local mod = string_gsub(k, ":.*", "")
			if mod ~= k then
				if mod ~= lastmod then
					lines[#lines + 1] = ""
					lines[#lines + 1] = "# " .. mod
					lastmod = mod
				end
				local r, g, b, a = extractcolor(v.mapcolor)
				if not r then r, g, b, a = heuristic(v) end
				if r then
					lines[#lines + 1] = k .. " " .. r
					.. " " .. g .. " " .. b .. ((a < 255)
						and (" " .. a) or "")
				else
					lines[#lines + 1] = "#--- MISSING/INVALID: " .. k
					missing[mod] = (missing[mod] or 0) + 1
				end
			end
		end
		if writefile then
			local f = io_open(minetest.get_worldpath() .. "/mapcolors.txt", "wb")
			f:write(table_concat(lines, "\n"))
			f:close()
		end
		if next(missing) then
			local warn = {"node definitions missing/invalid mapcolor:"}
			for k, v in sortedpairs(missing) do
				warn[#warn + 1] = k .. "(" .. v .. ")"
			end
			nodecore.log("warning", table_concat(warn, " "))
		end
	end)
