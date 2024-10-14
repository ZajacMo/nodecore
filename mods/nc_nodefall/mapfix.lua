-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs
    = core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local idsupport = {}
local idfalling = {}

local c_air = core.get_content_id("air")
local c_stone = core.get_content_id("nc_terrain:stone")

local function initdata()
	initdata = function() end
	for k, v in pairs(core.registered_nodes) do
		if v.walkable and not v.buildable_to then
			idsupport[core.get_content_id(k)] = true
		end
		if ((v.groups or {}).falling_node or 0) > 0
		and ((v.groups or {}).falling_mapgen_ignore or 0) <= 0 then
			idfalling[core.get_content_id(k)] = true
		end
	end
end

nc.register_mapgen_shared({
		label = "falling node mapgen fix",
		func = function(minp, maxp, area, data)
			initdata()
			local ai = area.index
			local ystride = area.ystride
			for z = minp.z, maxp.z do
				for x = minp.x, maxp.x do
					local offs = ai(area, x, minp.y, z)
					local support = false
					for _ = minp.y, maxp.y do
						local d = data[offs]
						if (not support) and idfalling[d] then
							if support == false then
								-- false at bottom, nil above
								data[offs] = c_stone
								support = true
							else
								data[offs] = c_air
							end
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
