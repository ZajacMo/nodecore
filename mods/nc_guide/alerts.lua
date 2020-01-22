-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local donecache = {}

local msg = "hint complete - @1"
nodecore.translate_inform(msg)

minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		local _, done = nodecore.hint_state(pname)
		local t = {}
		for _, v in pairs(done) do t[v.text] = true end
		donecache[pname] = t
	end)

nodecore.register_on_player_discover(function(player)
		local pname = player:get_player_name()
		local t = donecache[pname]
		if not t then return end
		local _, done = nodecore.hint_state(pname)
		for _, v in pairs(done) do
			if not t[v.text] then
				t[v.text] = true
				minetest.chat_send_player(pname, minetest.colorize("#e0ff80",
						nodecore.translate(msg, v.text)))
			end
		end
	end)
