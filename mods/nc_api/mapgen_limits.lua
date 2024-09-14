-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string, tonumber, vector
    = math, minetest, nodecore, string, tonumber, vector
local math_floor, string_format
    = math.floor, string.format
-- LUALOCALS > ---------------------------------------------------------

local limit = tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000

local chunksize = tonumber(minetest.get_mapgen_setting("chunksize")) or 5
chunksize = chunksize * 16
local limitchunks = math_floor(limit / chunksize)

local min = (-limitchunks + 0.5) * chunksize + 7.5
nodecore.map_limit_min = min
local max = (limitchunks - 0.5) * chunksize + 7.5
nodecore.map_limit_max = max

nodecore.log("info", string_format("mapgen limit: %d, chunk: %d, bounds: %0.1f to %0.1f",
		limit, chunksize, nodecore.map_limit_min, nodecore.map_limit_max))

function nodecore.within_map_limits(pos)
	return pos.x >= min
	and pos.y >= min
	and pos.z >= min
	and pos.x <= max
	and pos.y <= max
	and pos.z <= max
end

local function near_mapblock_state(pos, dist, func)
	pos = vector.floor(pos)

	-- Optimistic check for the center first
	if func(pos) then return true end

	if (not dist) or (dist < 1) then return end
	dist = math_floor(dist)

	-- Clamp area to check to map bounds; areas outside the map
	-- are always considered "loaded" and their ignores are
	-- treated as canonical.

	local zmin = pos.z - dist
	if zmin < min then zmin = min end
	local zmax = pos.z + dist
	if zmax > max then zmax = max end

	local ymin = pos.y - dist
	if ymin < min then ymin = min end
	local ymax = pos.y + dist
	if ymax > max then ymax = max end

	local xmin = pos.x - dist
	if xmin < min then xmin = min end
	local xmax = pos.x + dist
	if xmax > max then xmax = max end

	-- Check corners of area
	local step = dist * 2
	for z = zmin, zmax, step do
		pos.z = z
		for y = ymin, ymax, step do
			pos.y = y
			for x = xmin, xmax, step do
				pos.x = x
				if func(pos) then return true end
			end
		end
	end

	-- If area is wide enough to have entire mapblocks not
	-- covered by the center and corners, then check each
	-- mapblock in case internal ones are unloaded.
	if dist <= 16 then return end
	for z = zmin, zmax, 16 do
		pos.z = z
		for y = ymin, ymax, 16 do
			pos.y = y
			for x = xmin, xmax, 16 do
				pos.x = x
				if func(pos) then return true end
			end
		end
	end
end
nodecore.near_mapblock_state = near_mapblock_state

function nodecore.near_unloaded(pos, node, dist)
	if node and node.name and node.name ~= "ignore" then return end
	return near_mapblock_state(pos, dist, function(p)
			return not minetest.get_node_or_nil(p)
		end)
end

function nodecore.near_inactive(pos, _, dist)
	return near_mapblock_state(pos, dist, function(p)
			return not minetest.compare_block_status(p, "active")
		end)
end
