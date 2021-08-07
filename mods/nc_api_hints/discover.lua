-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, string, type, vector
    = minetest, nodecore, pairs, string, type, vector
local string_format, string_gsub
    = string.format, string.gsub
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_on_discover,
nodecore.registered_on_discovers
= nodecore.mkreg()

local cache = {}

local function loaddb(p)
	if nodecore.hints_disabled() then return end
	if not p then return end
	local player
	local pname
	if type(p) == "string" then
		player, pname = minetest.get_player_by_name(p), p
	else
		player, pname = p, p:get_player_name()
	end
	if not (player and pname) then return end

	local db = cache[pname]
	if not db then
		local s = player:get_meta():get_string(modname) or ""
		db = s and minetest.deserialize(s) or {}
		cache[pname] = db
	end

	return db, player, pname, function()
		player:get_meta():set_string(modname, minetest.serialize(db))
	end

end
nodecore.get_player_discovered = loaddb

local function discover(p, k)
	local db, player, pname, save = loaddb(p)
	if not db then return end

	if (type(k) == "table") then
		local dirty
		for kk in pairs(k) do
			dirty = dirty or not db[kk]
			db[kk] = true
		end
		if not dirty then return end
	else
		if db[k] then return end
		db[k] = true
	end

	minetest.log("action", string_format("player %q discovered %s", pname,
			string_gsub(minetest.serialize(k), "^return ", "")))
	for _, cb in pairs(nodecore.registered_on_discovers) do
		cb(player, k, pname, db)
	end
	save()
end
nodecore.player_discover = discover

------------------------------------------------------------------------
-- PLAYER EVENTS

local function reghook(func, stat, pwhom, npos, ppos)
	return func("stat hook", function(...)
			local t = {...}
			local whom = t[pwhom]
			if not (whom and whom:is_player()) then return end
			local n = npos and t[npos].name or nil
			if ppos then
				local pos = t[ppos]
				local stack = pos and nodecore.stack_get(pos)
				if stack and not stack:is_empty() then
					discover(whom, stat .. ":" .. stack:get_name())
				end
			end
			return discover(whom, n and (stat .. ":" .. n) or stat)
		end)
end
reghook(nodecore.register_on_punchnode, "punch", 3, 2, 1)
reghook(nodecore.register_on_dignode, "dig", 3, 2)
reghook(nodecore.register_on_placenode, "place", 3, 2)
reghook(nodecore.register_on_dieplayer, "die", 1)
reghook(nodecore.register_on_respawnplayer, "spawn", 1)
reghook(nodecore.register_on_joinplayer, "join", 1)

local function unpackreason(reason)
	if type(reason) ~= "table" then return reason or "?" end
	if reason.nc_type then return "nc", reason.nc_type end
	if reason.from then return reason.from, reason.type or nil end
	return reason.type or "?"
end

nodecore.register_on_player_hpchange("hurt/heal stats", function(whom, change, reason)
		if change < 0 then
			return discover(whom, "hurt:" .. unpackreason(reason))
		else
			return discover(whom, "heal:" .. unpackreason(reason))
		end
	end)

nodecore.register_on_cheat("cheat stats", function(player, reason)
		discover(player, "cheat: " .. unpackreason(reason))
	end)

nodecore.register_on_chat_message("chat message stats", function(name, msg)
		discover(name, "chat:" .. ((msg:sub(1, 1) == "/") and "command" or "message"))
	end)

------------------------------------------------------------------------
-- PLAYER SCAN

nodecore.register_playerstep({
		label = "inv",
		action = function(player, data, dtime)
			-- inventory
			local inv = player:get_inventory()
			local t = {}
			for i = 1, inv:get_size("main") do
				local stack = inv:get_stack("main", i)
				if not stack:is_empty() then
					t[stack:get_name()] = true
				end
			end
			for k in pairs(t) do
				discover(player, "inv:" .. k)
			end

			-- looking at
			local pt = data.raycast()
			if pt and pt.type == "node" and data.staring_pos
			and vector.equals(data.staring_pos, pt.under) then
				data.staring_time = data.staring_time + dtime
				if data.staring_time >= 0.8 then
					local nn = minetest.get_node(pt.under).name
					discover(player, "look:" .. nn)
					local stack = nodecore.stack_get(pt.under)
					if stack and not stack:is_empty() then
						discover(player, "look:" .. stack:get_name())
					end
				end
			else
				data.staring_pos = pt and pt.under
				data.staring_time = dtime
			end
		end
	})
