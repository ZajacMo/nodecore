-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, type
    = ipairs, minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

nodecore.hints = {}

local function conv(spec)
	if not spec then
		return function() return true end
	end
	if type(spec) == "function" then return spec end
	if type(spec) == "table" then
		local f = spec[1]
		if f == true then
			return function(db)
				for i = 2, #spec do
					if db[spec[i]] then return true end
				end
			end
		end
		return function(db)
			for i = 1, #spec do
				if not db[spec[i]] then return end
			end
			return true
		end
	end
	return function(db) return db[spec] end
end

function nodecore.addhint(text, goal, reqs)
	local hints = nodecore.hints
	local t = nodecore.translate(text)
	local h = {
		text = t,
		goal = conv(goal),
		reqs = conv(reqs)
	}
	hints[#hints + 1] = h
	return h
end

function nodecore.hint_state(player)
	local rawdb = nodecore.statsdb[type(player) == "string"
	and player or player:get_player_name()] or {}

	local db = {}
	for _, r in ipairs({"inv", "punch", "dig", "place", "craft", "witness"}) do
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

	local done = {}
	local found = {}
	for _, hint in ipairs(nodecore.hints) do
		if hint.goal(db) then
			done[#done + 1] = hint
		elseif hint.reqs(db) then
			found[#found + 1] = hint
		end
	end

	return found, done
end
