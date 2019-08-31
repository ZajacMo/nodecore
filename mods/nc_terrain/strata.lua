-- LUALOCALS < ---------------------------------------------------------
local error, ipairs, math, minetest, nodecore, pairs
    = error, ipairs, math, minetest, nodecore, pairs
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local thickness = 128

nodecore.stratadata = nodecore.memoize(function()
		local data = {}
		data.stratbyid = {}
		data.altsbyid = {}
		for k, v in pairs(minetest.registered_nodes) do
			if v.strata then
				local sn
				for s, n in ipairs(v.strata) do
					if n == k then sn = s end
				end
				if not sn then error(k .. " not found in own strata") end
				local cid = minetest.get_content_id(k)
				data.stratbyid[cid] = sn
				data.altsbyid[cid] = {}
				for s, n in ipairs(v.strata) do
					data.altsbyid[cid][s] = minetest.get_content_id(n)
				end
			end
		end
		return data
	end)

nodecore.register_mapgen_shared(function(minp, maxp, area, data)
		if minp.y > -64 then return end

		local ai = area.index
		local t = nodecore.hard_stone_strata
		local sd = nodecore.stratadata()
		local byid = sd.stratbyid
		local alts = sd.altsbyid

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				local raw = y / -thickness
				local strat = math_floor(raw)
				local dither = raw - strat
				if strat > t then
					strat = t
					dither = nil
				elseif dither > (4 / thickness) then
					dither = nil
				else
					dither = (dither * thickness + 1)/5
				end
				for x = minp.x, maxp.x do
					local i = ai(area, x, y, z)
					if byid[data[i]] then
						if dither and math_random() >= dither then
							data[i] = alts[data[i]][strat]
						else
							data[i] = alts[data[i]][strat + 1]
						end
					end
				end
			end
		end
	end,
	-100)
