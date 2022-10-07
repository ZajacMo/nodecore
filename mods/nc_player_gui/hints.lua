-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, math_random, table_insert
    = math.floor, math.random, table.insert
-- LUALOCALS > ---------------------------------------------------------

local pcache = {}

local strings = {
	progress = "@1 discovered, @2 available, @3 future",
	explore = "The discovery system only alerts you to the existence of"
	.. " some basic game mechanics. More advanced content, such as"
	.. " emergent systems and automation, you will have to"
	.. " invent yourself!",
	hint = "- @1",
	done = "- DONE: @1",
	future = "- FUTURE: @1"
}

for k, v in pairs(strings) do
	nodecore.translate_inform(v)
	strings[k] = function(...) return nodecore.translate(v, ...) end
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math_random(1, i)
		t[i], t[j] = t[j], t[i]
	end
end

local function gethint(player)
	local pname = player:get_player_name()

	local now = math_floor(minetest.get_us_time() / 1000000)
	local cached = pcache[pname]
	if cached and cached.time == now then return cached.found end

	local found, done = nodecore.hint_state(pname)
	local future
	if minetest.get_player_privs(pname).debug then
		local seen = {}
		for _, v in pairs(found) do seen[v] = true end
		for _, v in pairs(done) do seen[v] = true end
		future = {}
		for _, v in pairs(nodecore.hints) do
			if not seen[v] then
				future[#future + 1] = strings.future(v.text)
			end
		end
		shuffle(future)
	end
	for k, v in pairs(found) do found[k] = strings.hint(v.text) end
	shuffle(found)
	for k, v in pairs(done) do done[k] = strings.done(v.text) end
	shuffle(done)

	local prog = #found
	local left = #(nodecore.hints) - prog - #done

	table_insert(found, 1, "")
	table_insert(found, 1, strings.progress(#done, prog, left))
	found[#found + 1] = ""
	found[#found + 1] = strings.explore()
	found[#found + 1] = ""
	for i = 1, #done do found[#found + 1] = done[i] end
	if future then
		found[#found + 1] = ""
		for i = 1, #future do found[#found + 1] = future[i] end
	end

	pcache[pname] = {time = now, found = found}
	return found
end

local function clearcache(_, pname)
	pcache[pname] = nil
	return true
end

local mytab = {
	title = "Discovery",
	visible = function(_, player)
		return nodecore.interact(player)
		and not nodecore.hints_disabled()
		or false
	end,
	content = gethint,
	on_discover = clearcache,
	on_privchange = clearcache
}
nodecore.register_inventory_tab(mytab)

nodecore.register_on_discover(function(player)
		return nodecore.inventory_notify(player, "discover")
	end)
