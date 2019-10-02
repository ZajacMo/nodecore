-- LUALOCALS < ---------------------------------------------------------
local error, ipairs, minetest, nodecore
    = error, ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

function nodecore.ezschematic(key, yslices, init)
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
				data[(z - 1) * size.x * size.y + (y - 1) * size.x + x]
				= key[zs:sub(x, x)]
			end
		end
	end
	init = init or {}
	init.size = size
	init.data = data
	return minetest.register_schematic(init)
end
