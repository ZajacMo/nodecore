-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, table
    = ipairs, math, minetest, nodecore, pairs, table
local math_random, table_insert
    = math.random, table.insert
-- LUALOCALS > ---------------------------------------------------------

local dirs = nodecore.dirs()

function nodecore.scan_flood(pos, range, func)
	local q = {pos}
	local seen = {}
	for d = 0, range do
		local nxt = {}
		for _, p in ipairs(q) do
			local res = func(p, d)
			if res then return res end
			if res == nil then
				for _, v in pairs(dirs) do
					local np = {
						x = p.x + v.x,
						y = p.y + v.y,
						z = p.z + v.z,
						prev = p
					}
					local nk = minetest.hash_node_position(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						table_insert(nxt, np)
					end
				end
			end
		end
		if #nxt < 1 then break end
		for i = 1, #nxt do
			local j = math_random(1, #nxt)
			nxt[i], nxt[j] = nxt[j], nxt[i]
		end
		q = nxt
	end
end
