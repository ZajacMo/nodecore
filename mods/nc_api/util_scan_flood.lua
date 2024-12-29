-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, table
    = core, ipairs, nc, pairs, table
local table_shuffle
    = table.shuffle
-- LUALOCALS > ---------------------------------------------------------

local hashpos = core.hash_node_position
local dirs = nc.dirs()

-- Flood-fill scan using a taxicab (i.e. 6-neighbor) metric.

-- Each position within the scanned area is visited at most once. The
-- actual scanned area can be limited by the visit function indicating
-- that the position is an "obstacle".

-- pos: starting position (always visited)
-- range: maximum distance to scan; note that this is effectively
-- > recursion depth, not absolute distance, if obstacles are present.
-- func: visitor function to be called once per node position

-- The visitor function is passed the following parameters:
-- - position to be visited
-- - depth (distance traveled along path) from the start

-- The depth will always be the minimum possible value given any
-- obstacles present, i.e. this is essentially Dijkstra's pathfinding
-- algorithm with a naive uniform manhattan distance cost metric.

-- The visitor function may return a single value (additional return
-- values are ignored). The value will be interpreted as:

-- nil = no special behavior; continue scan.
-- false = do not add this position's neighbors to the scan queue (it
-- > represents an "obstacle"); those neighbors may still be added by
-- > other positions along other paths though.
-- anything else (truthy) = stop the scan immediately and return this
-- > value. This is used to make scan_flood operate as a "search"
-- > function returning the nearest result.

-- scan_flood will return whatever the first truthy return value from
-- the visitor function is, otherwise will return nothing.

function nc.scan_flood(pos, range, func)
	local q = {pos}
	local seen = {[hashpos(pos)] = true}
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
					local nk = hashpos(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						nxt[#nxt + 1] = np
					end
				end
			end
		end
		if #nxt < 1 then return end
		table_shuffle(nxt)
		q = nxt
	end
	-- Handle final depth specially, as there is no need
	-- to do many checks or add neighbors to the queue.
	for _, p in ipairs(q) do
		local res = func(p, range)
		if res then return res end
	end
end
