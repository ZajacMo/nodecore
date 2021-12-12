-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, table, type
    = ipairs, minetest, nodecore, pairs, table, type
local table_concat, table_insert, table_sort
    = table.concat, table.insert, table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local tabs = {}
nodecore.registered_inventory_tabs = tabs
function nodecore.register_inventory_tab(def)
	tabs[#tabs + 1] = def
	nodecore.translate_inform(def.title)
	if type(def.content) == "table" then
		for i = 1, #def.content do
			nodecore.translate_inform(def.content[i])
		end
	end
end

local nct = nodecore.translate
local fse = minetest.formspec_escape

local formwidth = 15
local formheight = formwidth / 2

local alltabswidth = formwidth - 0.25
local maxtabs = 7
local tabheight = 0.5
local tabmarginx = 0.2
local tabmarginy = 0.25
local tabmax = formwidth - 0.5

local textmarginx = 0.25
local textmarginy = 0.1
local textheight = formheight + 0.8

local metakey = modname .. "_inventory_key"
function nodecore.inventory_tab_get(player)
	local n = player:get_meta():get_int(metakey)
	return nodecore.registered_inventory_tabs[n] and n or 1
end
function nodecore.inventory_tab_set(player, tab)
	player:get_meta():set_int(metakey,
		tab and nodecore.registered_inventory_tabs[tab] and tab or 0)
end

function nodecore.inventory_formspec(player)
	local t = {
		"bgcolor[#000000C0;true]",
		"listcolors[#00000000;#00000000;#00000000;#000000FF;#FFFFFFFF]"
	}

	local tablist = {}
	for i, v in ipairs(nodecore.registered_inventory_tabs) do
		local vis = v.visible
		if type(vis) == "function" then vis = vis(v, player) end
		if vis == nil or vis then
			tablist[#tablist + 1] = {idx = i, tab = v}
		end
	end
	local tabqty = #tablist
	if tabqty > maxtabs then tabqty = maxtabs end
	local tabwidth = alltabswidth / tabqty
	local x = 0
	local y = 0
	local tabdata
	local curtab = nodecore.inventory_tab_get(player)
	for i, v in ipairs(tablist) do
		if curtab == v.idx then
			tabdata = v.tab
			t[#t + 1] = "box[" .. x .. "," .. (y + tabheight) .. ";"
			.. (tabwidth - 0.04) .. ",0.1;#ffffff]"
		end
		t[#t + 1] = "button[" .. x .. "," .. y .. ";"
		.. (tabwidth + tabmarginx) .. "," .. tabheight .. ";tab" .. i
		.. ";" .. fse(nct(v.tab.title)) .. "]"
		x = x + tabwidth
		if x >= tabmax then
			x = 0
			y = y + tabheight + tabmarginy
		end
	end
	if x > 0 then y = y + tabheight + tabmarginy end

	table_insert(t, 1, "size[" .. formwidth .. "," .. formheight + y .. "]")

	if tabdata then
		local content = tabdata.content
		if type(content) == "function" then
			content = content(player, {
					w = formwidth,
					h = textheight,
					x = textmarginx,
					y = y + textmarginy
				}, t)
		end
		if not content then return end
		if tabdata.raw then
			if type(content) == "table" then
				for _, v in ipairs(content) do t[#t + 1] = v end
			end
		else
			t[#t + 1] = "textarea[" .. textmarginx .. "," .. (y + textmarginy)
			.. ";" .. formwidth .. "," .. textheight .. ";;;"
			for _, v in ipairs(content) do t[#t + 1] = fse(nct(v) .. "\n") end
			t[#t + 1] = "]"
		end
	end

	return table_concat(t)
end

local invspeccache = {}
minetest.register_on_leaveplayer(function(player)
		invspeccache[player:get_player_name()] = nil
	end)
function nodecore.inventory_formspec_update(player)
	local str = nodecore.inventory_formspec(player)
	local pname = player:get_player_name()
	if invspeccache[pname] == str then return str end
	player:set_inventory_formspec(str)
	invspeccache[pname] = str
	return str
end

nodecore.register_on_joinplayer("join set inv formspec", nodecore.inventory_formspec_update)

nodecore.register_on_player_receive_fields("player inv formspec returned",
	function(player, formname, fields)
		if formname == "" then
			local tab
			for i = 1, #nodecore.registered_inventory_tabs do
				if fields["tab" .. i] then
					tab = i
					break
				end
			end
			if tab then
				nodecore.inventory_tab_set(player, tab)
				return minetest.show_formspec(player:get_player_name(),
					formname, nodecore.inventory_formspec_update(player))
			end
			nodecore.inventory_formspec_update(player)
		end
	end)

local pending = {}
function nodecore.inventory_notify(pname, event)
	pname = type(pname) == "string" and pname or pname:get_player_name()
	local key = pname .. "|" .. event
	if pending[key] then return end
	pending[key] = true
	minetest.after(0, function()
			pending[key] = nil

			local player = minetest.get_player_by_name(pname)
			if not player then return end

			local tab = nodecore.inventory_tab_get(player)
			tab = tab and nodecore.registered_inventory_tabs[tab]
			local evt = tab and tab["on_" .. event]
			if type(evt) == "function" then evt = evt(player, pname) end
			if evt then return nodecore.inventory_formspec_update(player) end
		end)
end

nodecore.register_playerstep({
		label = "hint tab watch interact",
		action = function(player, data)
			local privs = {}
			for k, v in pairs(minetest.get_player_privs(data.pname)) do
				if v then privs[#privs + 1] = k end
			end
			table_sort(privs)
			privs = table_concat(privs, ",")
			if privs == data.privstring then return end
			data.privstring = privs
			return nodecore.inventory_notify(player, "privchange")
		end
	})
