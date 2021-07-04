-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, table, type
    = ipairs, minetest, nodecore, table, type
local table_concat, table_insert
    = table.concat, table.insert
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

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

local tabwidth = (formwidth - 0.25) / 7
local tabheight = 0.5
local tabmarginx = tabwidth + 0.2
local tabmarginy = tabheight + 0.25
local tabmax = formwidth - 0.5

local textmarginx = 0.25
local textmarginy = 0.1
local textheight = formheight + 0.8

function nodecore.inventory_formspec(player, curtab)
	local t = {
		"bgcolor[#000000C0;true]",
		"listcolors[#00000000;#00000000;#00000000;#000000FF;#FFFFFFFF]"
	}

	local x = 0
	local y = 0
	local content
	for i, v in ipairs(nodecore.registered_inventory_tabs) do
		local vis = v.visible
		if type(vis) == "function" then vis = vis(v, player) end
		if vis == nil or vis then
			t[#t + 1] = "button[" .. x .. "," .. y .. ";"
			.. tabmarginx .. "," .. tabheight .. ";tab" .. i
			.. ";" .. fse(nct(v.title)) .. "]"
			if curtab == i or (not curtab and i == 1) then
				content = v.content
			end
			x = x + tabwidth
			if x >= tabmax then
				x = 0
				y = y + tabmarginy
			end
		end
	end
	if x > 0 then y = y + tabmarginy end

	table_insert(t, 1, "size[" .. formwidth .. "," .. formheight + y .. "]")

	if content then
		t[#t + 1] = "textarea[" .. textmarginx .. "," .. (y + textmarginy)
		.. ";" .. formwidth .. "," .. textheight .. ";;;"
		if type(content) == "function" then content = content(player) end
		for i = 1, #content do t[#t + 1] = fse(nct(content[i]) .. "\n") end
		t[#t + 1] = "]"
	end

	return table_concat(t)
end

nodecore.register_on_joinplayer("join set inv formspec", function(player)
		player:set_inventory_formspec(nodecore.inventory_formspec(player))
	end)

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
				minetest.show_formspec(player:get_player_name(), formname,
					nodecore.inventory_formspec(player, tab))
			end
		end
	end)
