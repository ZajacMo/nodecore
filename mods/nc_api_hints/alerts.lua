-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, pairs, table
    = core, ipairs, math, nc, pairs, table
local math_random, table_concat, table_sort
    = math.random, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

local donecache = {}
local msgcache = {}

local msg = "discovered - @1"
nc.translate_inform(msg)

local function hintinit(player)
	local pname = player:get_player_name()
	local _, done = nc.hint_state(pname)
	local t = {}
	for _, v in pairs(done) do t[v.text] = true end
	donecache[pname] = t
	msgcache[pname] = {}
end
nc.register_on_joinplayer(hintinit)

local function alertcheck(pname)
	local dc = donecache[pname]
	if not dc then return end
	local mc = msgcache[pname]
	if not mc then return end

	local _, done = nc.hint_state(pname)
	for _, v in pairs(done) do
		if not dc[v.text] then
			dc[v.text] = true
			mc[v.text] = nc.gametime + 10
		end
	end
end
nc.register_on_discover(function(_, key, pname)
		if not key then donecache[pname] = {} end
		return alertcheck(pname)
	end)

do
	local queue = {}
	local function scan()
		if #queue > 0 then
			local pname = queue[#queue]
			queue[#queue] = nil
			local player = core.get_player_by_name(pname)
			if player then alertcheck(pname) end
			return core.after(0, scan)
		else
			return core.after(2 + math_random() * 3, function()
					queue = {}
					for _, p in ipairs(core.get_connected_players()) do
						queue[#queue + 1] = p:get_player_name()
					end
					return core.after(0, scan)
				end)
		end
	end
	core.after(0, scan)
end

nc.register_playerstep({
		label = "hint alerts",
		action = function(player, data)
			if nc.hints_disabled() then return end

			if not nc.interact(player) then
				data.hints_nointeract = true
			elseif data.hints_nointeract then
				data.hints_nointeract = nil
				hintinit(player)
			end

			local mc = msgcache[data.pname] or {}
			local t = {}
			local o = {}
			for k, v in pairs(mc) do
				if v < nc.gametime then
					mc[k] = nil
				else
					t[#t + 1] = nc.translate(msg, k)
					o[t[#t]] = v
				end
			end
			table_sort(t, function(a, b)
					return o[a] < o[b] or o[a] == o[b] and a < b
				end)
			nc.hud_set_multiline(player, {
					label = "hintcomplete",
					hud_elem_type = "text",
					position = {x = 0.5, y = 0.25},
					text = table_concat(t, "\n"),
					number = 0xE0FF80,
					alignment = {x = 0, y = 0},
					offset = {x = 0, y = 0}
				}, nc.translate)
		end
	})
