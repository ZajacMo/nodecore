-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, table
    = core, ipairs, nc, pairs, table
local table_insert, table_shuffle
    = table.insert, table.shuffle
-- LUALOCALS > ---------------------------------------------------------

local dirs = nc.dirs()

-- Scans pos, then its 6 neighbors, then their neighbors, recursively.
-- Neighbors at the same distance are scanned in random order.
-- Distance is 0 at pos, 1 at its 6 neighbors, 2 at theirs (taxicab distance).
-- func(position, distance) is called at most once for each position within 'range' distance of pos (inclusive).
-- If func returns nil then the scan continues as normal.
-- If func returns false then that position's neighbors will not be queued, though they may later be visited by a longer route.
-- If func returns anything else then the whole scan stops.

function nc.scan_flood(pos, range, func)
	local q = {pos}
	local seen = {[core.hash_node_position(pos)] = true}
	for d = 0, range - 1 do
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
					local nk = core.hash_node_position(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						table_insert(nxt, np)
					end
				end
			end
		end
		if #nxt < 1 then return end
		table_shuffle(nxt)
		q = nxt
	end
	for _, p in ipairs(q) do
		local res = func(p, range)
		if res then return res end
	end
end
