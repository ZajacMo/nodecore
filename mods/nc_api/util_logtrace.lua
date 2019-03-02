-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, print, table, type
    = ipairs, minetest, nodecore, pairs, print, table, type
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

minetest.register_privilege("logtrace", "Receive server debug/trace messages.")

core.register_chatcommand("logtrace", {
		description = "Toggle debug trace messages",
		privs = {logtrace = true},
		func = function(name)
			local player = minetest.get_player_by_name(name)
			if not player then return end
			local old = player:get_attribute("logtrace") or ""
			return player:set_attribute("logtrace", (old == "") and "1" or "")
		end,
	})

function nodecore.logtrace(...)
	local t = {"#", ...}
	for i, v in ipairs(t) do
		if type(v) == "table" then
			t[i] = minetest.serialize(v):sub(("return "):length())
		end
	end
	local msg = table_concat(t, " ")
	for _, p in pairs(minetest.get_connected_players()) do
		local n = p:get_player_name()
		if minetest.get_player_privs(n).logtrace then
			local a = p:get_attribute("logtrace")
			if a and a ~= "" then
				minetest.chat_send_player(n, msg)
			end
		end
	end
end

local function tracify(func)
	return function(...)
		nodecore.logtrace(...)
		return func(...)
	end
end
print = tracify(print)
minetest.log = tracify(minetest.log)
