-- LUALOCALS < ---------------------------------------------------------
local nodecore, pairs, table
    = nodecore, pairs, table
local table_concat, table_sort
    = table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local donecache = {}
local msgcache = {}

local msg = "challenge complete - @1"
nodecore.translate_inform(msg)

local function hintinit(player)
	local pname = player:get_player_name()
	local _, done = nodecore.hint_state(pname)
	local t = {}
	for _, v in pairs(done) do t[v.text] = true end
	donecache[pname] = t
	msgcache[pname] = {}
end
nodecore.register_on_joinplayer("join hint setup", hintinit)

nodecore.register_on_discover(function(_, key, pname)
		if not key then donecache[pname] = {} end
		local dc = donecache[pname]
		if not dc then return end
		local mc = msgcache[pname]
		if not mc then return end

		local _, done = nodecore.hint_state(pname)
		for _, v in pairs(done) do
			if not dc[v.text] then
				dc[v.text] = true
				mc[v.text] = nodecore.gametime + 10
			end
		end
	end)

nodecore.register_playerstep({
		label = "hint alerts",
		action = function(player, data)
			if nodecore.hints_disabled() then return end

			if not nodecore.interact(player) then
				data.hints_nointeract = true
			elseif data.hints_nointeract then
				data.hints_nointeract = nil
				hintinit(player)
			end

			local mc = msgcache[data.pname] or {}
			local t = {}
			local o = {}
			for k, v in pairs(mc) do
				if v < nodecore.gametime then
					mc[k] = nil
				else
					t[#t + 1] = nodecore.translate(msg, k)
					o[t[#t]] = v
				end
			end
			table_sort(t, function(a, b)
					return o[a] < o[b] or o[a] == o[b] and a < b
				end)
			nodecore.hud_set_multiline(player, {
					label = "hintcomplete",
					hud_elem_type = "text",
					position = {x = 0.5, y = 0.25},
					text = table_concat(t, "\n"),
					number = 0xE0FF80,
					alignment = {x = 0, y = 0},
					offset = {x = 0, y = 0}
				}, nodecore.translate)
		end
	})
