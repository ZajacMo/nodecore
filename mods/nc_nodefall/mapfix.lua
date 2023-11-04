-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local transform = {
	["nc_terrain:gravel"] = "nc_terrain:cobble",
	["nc_terrain:sand"] = "nc_concrete:sandstone",
}
local idsupport = {}
local idxform = {}

local function initdata()
	initdata = function() end
	for k, v in pairs(minetest.registered_nodes) do
		if v.walkable and not v.buildable_to then
			idsupport[minetest.get_content_id(k)] = true
		end
		if transform[k] then
			idxform[minetest.get_content_id(k)]
			= minetest.registered_nodes[transform[k]]
			and minetest.get_content_id(transform[k])
			or nil
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
						if not support then
							local xf = idxform[d]
							if xf then
								d = xf
								data[offs] = d
							end
						end
						support = idsupport[d]
						offs = offs + ystride
					end
				end
			end
		end,
		priority = -200
	})
