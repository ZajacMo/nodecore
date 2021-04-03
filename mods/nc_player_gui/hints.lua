-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, table_insert, table_sort
    = math.floor, table.insert, table.sort
-- LUALOCALS > ---------------------------------------------------------

local pcache = {}

local strings = {
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
	table_sort(found)
	for k, v in pairs(done) do done[k] = strings.done(v.text) end
	table_sort(done)

	local prog = #found
	local left = #(nodecore.hints) - prog - #done

	table_insert(found, 1, "")
	table_insert(found, 1, strings.progress(#done, prog, left))
	found[#found + 1] = ""
	found[#found + 1] = strings.explore()
	found[#found + 1] = ""
	for i = 1, #done do found[#found + 1] = done[i] end

	pcache[pname] = {time = now, found = found}
	return found
end

nodecore.register_inventory_tab({
		title = "Hints",
		visible = function() return not nodecore.hints_disabled() end,
		content = gethint
	})
