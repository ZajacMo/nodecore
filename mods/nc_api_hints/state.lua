-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, string
    = ipairs, minetest, nodecore, pairs, string
local string_gsub, string_match, string_sub
    = string.gsub, string.match, string.sub
-- LUALOCALS > ---------------------------------------------------------

local expandcache = {}
local function expandkey(k)
	local keys = expandcache[k]
	if keys then return keys end

	keys = {}
	keys[k] = true
	for name, def in pairs(minetest.registered_items) do
		if string_sub(k, -#name) == name then
			local pref = string_sub(k, 1, #k - #name)
			for g in pairs(def.groups or {}) do
				keys[pref .. "group:" .. g] = true
			end
			if def.tool_capabilities and def.tool_capabilities.groupcaps then
				for gn, gv in pairs(def.tool_capabilities.groupcaps) do
					for gt, gtv in pairs(gv.times or {}) do
						if gtv <= 4 then
							keys[pref .. "toolcap:" .. gn] = true
							keys[pref .. "toolcap:" .. gn
							.. ":" .. gt] = true
						end
					end
				end
			end
		end
	end

	local rawkeys = keys
	keys = {}
	for r in pairs(rawkeys) do
		keys[r] = true
		while string_match(r, ":") do
			r = string_gsub(r, "^[^:]*:", "")
			keys[r] = true
		end
	end

	local t = {}
	for x in pairs(keys) do t[#t + 1] = x end
	expandcache[k] = t
	return t
end

function nodecore.hint_state(pspec)
	local rawdb, player, pname = nodecore.get_player_discovered(pspec)
	if not rawdb then return {}, {} end

	local db = {}
	for k in pairs(rawdb) do
		local exp = expandkey(k)
		for i = 1, #exp do db[exp[i]] = true end
	end

	local done = {}
	local found = {}
	for _, hint in ipairs(nodecore.hints) do
		if hint.goal(db, pname, player) then
			done[#done + 1] = hint
		elseif (not hint.hide) and hint.reqs(db, pname, player) then
			found[#found + 1] = hint
		end
	end

	return found, done
end
