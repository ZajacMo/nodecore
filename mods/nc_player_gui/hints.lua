-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, math_random, table_remove, table_sort
    = math.floor, math.random, table.remove, table.sort
-- LUALOCALS > ---------------------------------------------------------

local pcache = {}

local strings = {
	onemore = "(and 1 more hint)",
	fewmore = "(and @1 more hints)",
	progress = "Progress: @1 complete, @2 current, @3 future",
	explore = "Not all game content is covered by hints. Explore!",
	hint = "- @1",
	done = "- DONE: @1"
}

for k, v in pairs(strings) do
	nodecore.translate_inform(v)
	strings[k] = function(...) return nodecore.translate(v, ...) end
end

local function gethint(player)
	local pname = player:get_player_name()

	local now = math_floor(minetest.get_us_time() / 1000000)
	local cached = pcache[pname]
	if cached and cached.time == now then return cached.found end

	local found, done = nodecore.hint_state(pname)
	for k, v in pairs(found) do found[k] = strings.hint(v.text) end
	for k, v in pairs(done) do done[k] = strings.done(v.text) end

	local prog = #found
	local left = #(nodecore.hints) - prog - #done

	while #found > 5 do
		table_remove(found, math_random(1, #found))
	end
	while #found < 5 and #done > 0 do
		local j = math_random(1, #done)
		found[#found + 1] = done[j]
		table_remove(done, j)
	end
	table_sort(found)
	if #found == (prog - 1) then
		found[#found + 1] = strings.onemore()
	elseif #found < prog then
		found[#found + 1] = strings.fewmore(prog - #found)
	end

	found[#found + 1] = ""
	found[#found + 1] = strings.progress(#done, prog, left)
	found[#found + 1] = strings.explore()

	pcache[pname] = {time = now, found = found}
	return found
end

nodecore.register_inventory_tab({
		title = "Hints",
		visible = function() return not nodecore.hints_disabled() end,
		content = gethint
	})
