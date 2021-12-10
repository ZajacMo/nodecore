-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, math_random, table_insert
    = math.floor, math.random, table.insert
-- LUALOCALS > ---------------------------------------------------------

local pcache = {}

local strings = {
	progress = "Progress: @1 complete, @2 current, @3 future",
	explore = "Not all game content is covered by challenges. Explore!",
	hint = "- @1",
	done = "- DONE: @1"
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

	pcache[pname] = {time = now, found = found}
	return found
end

local function clearcache(_, pname)
	pcache[pname] = nil
	return true
end

local mytab = {
	title = "Challenges",
	visible = function(_, player)
		return nodecore.interact(player)
		and not nodecore.hints_disabled()
		or false
	end,
	content = gethint,
	on_discover = clearcache,
	on_priv_interact = clearcache
}
nodecore.register_inventory_tab(mytab)

nodecore.register_on_discover(function(player)
		return nodecore.inventory_notify(player, "discover")
	end)
nodecore.register_playerstep({
		label = "hint tab watch interact",
		action = function(player, data)
			local inter = nodecore.interact(player) or false
			if inter == data.priv_interact then return end
			data.priv_interact = inter
			return nodecore.inventory_notify(player, "priv_interact")
		end
	})
