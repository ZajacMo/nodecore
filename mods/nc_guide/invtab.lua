-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, table
    = ipairs, math, minetest, nodecore, pairs, table
local math_floor, math_random, table_remove, table_sort
    = math.floor, math.random, table.remove, table.sort
-- LUALOCALS > ---------------------------------------------------------

local pcache = {}

local strings = {
	onemore = "...and 1 more hint...",
	fewmore = "...and @1 more hints...",
	progress = "Progress: @1 complete, @2 current, @3 future",
	explore = "Not all game content is covered by hints. Explore!"
}

for k, v in pairs(strings) do
	nodecore.translate_inform(v)
	strings[k] = function(...) return nodecore.translate(v, ...) end
end

local function gethint(player)
	local pname = player:get_player_name()

	local now = math_floor(minetest.get_us_time() / 1000000 / 5)
	local cached = pcache[pname]
	if cached and cached.time == now then return cached.found end

	local rawdb = nodecore.statsdb[pname] or {}
	local db = {}
	for _, r in ipairs({"inv", "punch", "dig", "place", "craft"}) do
		for k, v in pairs(rawdb[r] or {}) do
			db[k] = v
			db[r .. ":" .. k] = v
		end
	end
	for k, v in pairs(minetest.registered_items) do
		if db[k] then
			if v.tool_capabilities and v.tool_capabilities.groupcaps then
				for gn, gv in pairs(v.tool_capabilities.groupcaps) do
					for gt in pairs(gv.times or {}) do
						db["toolcap:" .. gn .. ":" .. gt] = true
					end
				end
			end
			for gn, gv in pairs(v.groups or {}) do
				db["group:" .. gn] = gv
			end
		end
	end

	local done = 0
	local found = {}
	for _, hint in ipairs(nodecore.hints) do
		if hint.goal(db) then
			done = done + 1
		elseif hint.reqs(db) then
			found[#found + 1] = hint.text
		end
	end
	local prog = #found
	local left = #(nodecore.hints) - prog - done

	while #found > 5 do
		table_remove(found, math_random(1, #found))
	end
	table_sort(found)
	if #found == (prog - 1) then
		found[#found + 1] = strings.onemore()
	elseif #found < prog then
		found[#found + 1] = strings.fewmore(prog - #found)
	end

	found[#found + 1] = ""
	found[#found + 1] = strings.progress(done, prog, left)
	found[#found + 1] = strings.explore()

	pcache[pname] = {time = now, found = found}
	return found
end

nodecore.register_inventory_tab({
		title = "Hints",
		content = gethint
	})
