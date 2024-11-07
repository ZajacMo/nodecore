-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, table
    = core, ipairs, nc, pairs, table
local table_insert, table_shuffle
    = table.insert, table.shuffle
-- LUALOCALS > ---------------------------------------------------------

local dirs = nc.dirs()

function nc.scan_flood(pos, range, func)
	local q = {pos}
	local seen = {}
	seen[core.hash_node_position(pos)] = true
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
					local nk = core.hash_node_position(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						table_insert(nxt, np)
					end
				end
			end
		end
		if #nxt < 1 then break end
		table_shuffle(nxt)
		q = nxt
	end
end
