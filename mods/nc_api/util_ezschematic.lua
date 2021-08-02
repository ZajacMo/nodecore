-- LUALOCALS < ---------------------------------------------------------
local error, ipairs, minetest, nodecore, pairs, string, table
    = error, ipairs, minetest, nodecore, pairs, string, table
local string_format, table_sort
    = string.format, table.sort
-- LUALOCALS > ---------------------------------------------------------

function nodecore.ezschematic(key, yslices, init)
	local totals = {}
	local size = {}
	local data = {}
	size.y = #yslices
	for y, ys in ipairs(yslices) do
		if size.z and size.z ~= #ys then error("inconsistent z size") end
		size.z = #ys
		for z, zs in ipairs(ys) do
			if size.x and size.x ~= #zs then error("inconsistent x size") end
			size.x = #zs
			for x = 1, zs:len() do
				local node = key[zs:sub(x, x)]
				if node and node.name then
					totals[node.name] = (totals[node.name] or 0) + 1
				end
				data[(z - 1) * size.x * size.y + (y - 1) * size.x + x] = node
			end
		end
	end
	init = init or {}
	init.size = size
	init.data = data

	local keys = {}
	for k in pairs(totals) do keys[#keys + 1] = k end
	table_sort(keys, function(a, b) return totals[a] > totals[b] end)
	local report = string_format("ezschematic %s %dx%dx%d",
		minetest.get_current_modname() or "runtime",
		#yslices[1][1], #yslices, #yslices[1])
	for _, k in ipairs(keys) do
		report = string_format("%s, %d %s", report, totals[k], k)
	end
	nodecore.log("action", report)

	return minetest.register_schematic(init)
end
