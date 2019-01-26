-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
= math, minetest, nodecore, pairs, table
local math_floor, math_mod, math_pi, math_random, math_sin,
table_concat
= math.floor, math.mod, math.pi, math.random, math.sin,
table.concat
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local http = minetest.request_http_api()
if http then

	local store = nodecore.surveydata.store
	local players = nodecore.surveydata.players

	local function report()
		local t = store:to_table().fields
		t.players = players
		t.player_knowledge = nodecore.player_knowledge()
		for k, v in pairs(t.player_knowledge) do
			t.player_knowledge[k] = minetest.deserialize(v)
		end
		return http.fetch({
				url = "https://ec.mine.nu/nodecoresurvey/post",
				post_data = minetest.write_json(t),
				extra_headers = {["Content-Type"] = "application/json"}
			},
			function(res)
				return minetest.log(modname .. ": " .. minetest.serialize(res))
			end)
	end
	minetest.register_on_shutdown(report)
	local function reporttimer()
		minetest.after(300, reporttimer)
		report()
	end
	reporttimer()

elseif minetest.settings:get(modname .. "_off") == nil then

	local theta = math_pi * math_random() * 2
	local hd = "0123456789ABCDEF"
	local function hex(n)
		local a = math_floor(n / 16) + 1
		local b = math_mod(n, 16) + 1
		return hd:sub(a, a) .. hd:sub(b, b)
	end
	local function colorfancy(t)
		local c = {}
		for i = 1, #t do
			local b = math_floor((math_sin(theta) / 2 + 1/2) * 255)
			local y = 255 - b
			theta = theta + 0.2
			c[#c + 1] = minetest.colorize("#" .. hex(y) .. hex(y) .. hex(255 - y), t:sub(i, i))
		end
		return table_concat(c)
	end

	minetest.register_on_joinplayer(function(player)
			local pn = player:get_player_name()
			local function s(t) return minetest.chat_send_player(pn, t) end
			local c = minetest.colorize
			s(colorfancy("\n" .. ("="):rep(80)))
			s("Welcome to NodeCore!  Please support the "
					.. "game's development by enabling anonymous "
					.. "statisics collection!\nUse the \""
				.. c("#80FF00", "/" .. modname)
				.. "\" command to learn more, or set the \""
				.. c("#FF8000", modname .. "_off")
				.. "\" setting to disable this message.")
			s(colorfancy(("="):rep(80) .. "\n"))
		end)
end
