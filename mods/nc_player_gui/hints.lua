-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, string, table
    = ipairs, math, minetest, nodecore, pairs, string, table
local math_floor, math_random, string_sub, table_insert, table_sort
    = math.floor, math.random, string.sub, table.insert, table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local pcache = {}
local ordercache = {}

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

local function sort_by_time(pname, pmeta, tbl, suff)
	local ordering = ordercache[pname .. "|" .. suff]
	local metakey = modname .. "_hintsort_" .. suff
	if not ordering then
		local raw = pmeta:get_string(metakey)
		ordering = raw and raw ~= "" and minetest.deserialize(raw) or {}
		ordercache[pname] = ordering
	end

	local keys = {}
	local revkeys = {}
	for _, s in ipairs(tbl) do
		local k = string_sub(minetest.sha1(s), 1, 8)
		keys[s] = k
		revkeys[k] = s
	end

	local dirty
	for _, v in ipairs(tbl) do
		if not ordering[keys[v]] then
			ordering[keys[v]] = nodecore.gametime - math_random() / 1000
			dirty = true
		end
	end
	local t = {}
	for k in pairs(ordering) do t[#t + 1] = k end
	for _, k in ipairs(t) do
		if not revkeys[k] then
			ordering[k] = nil
			dirty = true
		end
	end

	if dirty then pmeta:set_string(metakey, minetest.serialize(ordering)) end

	table_sort(tbl, function(a, b) return ordering[keys[a]] > ordering[keys[b]] end)
end

local function gethint(player)
	local pname = player:get_player_name()

	local now = math_floor(minetest.get_us_time() / 1000000)
	local cached = pcache[pname]
	if cached and cached.time == now then return cached.found end

	local found, done = nodecore.hint_state(pname)
	local future
	local pmeta = player:get_meta()
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
		sort_by_time(pname, pmeta, future, "future")
	end
	for k, v in pairs(found) do found[k] = strings.hint(v.text) end
	for k, v in pairs(done) do done[k] = strings.done(v.text) end
	sort_by_time(pname, pmeta, found, "found")
	sort_by_time(pname, pmeta, done, "done")

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
