-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, string
    = ipairs, minetest, nodecore, pairs, string
local string_gsub, string_match
    = string.gsub, string.match
-- LUALOCALS > ---------------------------------------------------------

function nodecore.hint_state(pspec)
	local rawdb, player, pname = nodecore.get_player_discovered(pspec)
	if not rawdb then return {}, {} end

	local db = {}
	for k in pairs(rawdb) do
		db[k] = true
		while string_match(k, ":") do
			k = string_gsub(k, "^[^:]*:", "")
			db[k] = true
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

	local done = {}
	local found = {}
	for _, hint in ipairs(nodecore.hints) do
		if hint.goal(db, pname, player) then
			done[#done + 1] = hint
		elseif hint.reqs(db, pname, player) then
			found[#found + 1] = hint
		end
	end

	return found, done
end
