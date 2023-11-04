-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local idsupport = {}
local idfalling = {}

local c_air = minetest.get_content_id("air")

local function initdata()
	initdata = function() end
	for k, v in pairs(minetest.registered_nodes) do
		if v.walkable and not v.buildable_to then
			idsupport[minetest.get_content_id(k)] = true
		end
		if ((v.groups or {}).falling_node or 0) > 0 then
			idfalling[minetest.get_content_id(k)] = true
		end
	end
end

nodecore.register_mapgen_shared({
		label = "falling node mapgen fix",
		func = function(minp, maxp, area, data)
			initdata()
			local ai = area.index
			local ystride = area.ystride
			for z = minp.z, maxp.z do
				for x = minp.x, maxp.x do
					local offs = ai(area, x, minp.y, z)
					local support
					for _ = minp.y, maxp.y do
						local d = data[offs]
						if (not support) and idfalling[d] then
							data[offs] = c_air
						else
							support = idsupport[d]
						end
						offs = offs + ystride
					end
				end
			end
		end,
		priority = -200
	})
