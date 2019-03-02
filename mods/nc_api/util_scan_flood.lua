-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, next, nodecore, pairs, table
    = ipairs, math, minetest, next, nodecore, pairs, table
local math_random, table_insert
    = math.random, table.insert
-- LUALOCALS > ---------------------------------------------------------

local dirs = nodecore.dirs()

function nodecore.scan_flood(pos, range, func)
	local q = {pos}
	local seen = { }
	for d = 0, range do
		local next = {}
		for i, p in ipairs(q) do
			local res = func(p, d)
			if res then return res end
			if res == nil then
				for k, v in pairs(dirs) do
					local np = {
						x = p.x + v.x,
						y = p.y + v.y,
						z = p.z + v.z
					}
					local nk = minetest.hash_node_position(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						table_insert(next, np)
					end
				end
			end
		end
		if #next < 1 then break end
		for i = 1, #next do
			local j = math_random(1, #next)
			next[i], next[j] = next[j], next[i]
		end
		q = next
	end
end
