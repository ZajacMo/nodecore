-- LUALOCALS < ---------------------------------------------------------
local math, nc, pairs, table, vector
    = math, nc, pairs, table, vector
local math_random, table_sort
    = math.random, table.sort
-- LUALOCALS > ---------------------------------------------------------

local settleorder = {}

local groups = {}
local keys = {}
for x = -5, 5 do
	for y = -5, 5 do
		for z = -5, 5 do
			local p = {
				x = x,
				y = y,
				z = z,
			}
			local d = vector.length(p)
			if d <= 5 then
				p.v = d + p.y / 100
				local g = groups[p.v]
				if not g then
					g = {}
					groups[p.v] = g
					keys[#keys + 1] = p.v
				end
				g[#g + 1] = p
			end
		end
	end
end
table_sort(keys)
for _, k in pairs(keys) do
	local stamp = 0
	local t = groups[k]
	settleorder[#settleorder + 1] = function()
		if stamp == nc.gametime then return t end
		local n = #t
		if n < 2 then return t end
		for i = n, 2, -1 do
			local j = math_random(1, i)
			local x = t[i]
			t[i] = t[j]
			t[j] = x
		end
		stamp = nc.gametime
		return t
	end
end

function nc.settlescan()
	local i = 0
	local grp = {}
	local j = 0
	return function()
		if j >= #grp then
			if i >= #settleorder then
				return
			end
			i = i + 1
			grp = settleorder[i]()
			j = 0
		end
		j = j + 1
		return grp[j]
	end
end
