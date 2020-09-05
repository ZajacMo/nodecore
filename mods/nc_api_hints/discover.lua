-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, string, type
    = minetest, nodecore, pairs, string, type
local string_format
    = string.format
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

	return db, player, pname
end
nodecore.get_player_discovered = loaddb

local function discover(p, k)
	local db, player, pname = loaddb(p)
	if not db then return end

	if db[k] then return end

	db[k] = true
	player:get_meta():set_string(modname, minetest.serialize(db))
	minetest.log("action", string_format("player %q discovered %q", pname, k))
	for _, cb in pairs(nodecore.registered_on_discovers) do
		cb(player, k, pname, db)
	end
end
nodecore.player_discover = discover

------------------------------------------------------------------------
-- PLAYER EVENTS

local function reghook(func, stat, pwhom, npos)
	return func("stat hook", function(...)
			local t = {...}
			local whom = t[pwhom]
			local n = npos and t[npos].name or nil
			return discover(whom, n and (stat .. ":" .. n) or stat)
		end)
end
reghook(nodecore.register_on_punchnode, "punch", 3, 2)
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
-- PLAYER INVENTORY SCAN

nodecore.register_playerstep({
		label = "inv",
		action = function(player)
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
		end
	})
