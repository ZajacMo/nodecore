-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, print, table, type
    = ipairs, minetest, nodecore, pairs, print, table, type
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

minetest.register_privilege("logtrace", "Receive server debug/trace messages.")

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
			minetest.chat_send_player(n, msg)
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
