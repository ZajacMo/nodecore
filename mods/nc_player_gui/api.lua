-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, table, type
    = ipairs, minetest, nodecore, table, type
local table_concat, table_insert
    = table.concat, table.insert
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

nodecore.register_inventory_tab,
nodecore.registered_inventory_tabs
= nodecore.mkreg()

local nct = nodecore.translate

local fse = minetest.formspec_escape
function nodecore.inventory_formspec(player, curtab)
	local t = {
		"bgcolor[#000000C0;true]",
		"listcolors[#00000000;#00000000;#00000000;#000000FF;#FFFFFFFF]"
	}

	local x = 0
	local y = 0
	local content
	for i, v in ipairs(nodecore.registered_inventory_tabs) do
		t[#t + 1] = "button[" .. x .. "," .. y
		.. ";2.2,0.5;tab" .. i .. ";" .. fse(nct(v.title)) .. "]"
		if curtab == i or (not curtab and i == 1) then
			content = v.content
		end
		x = x + 2
		if x >= 12 then
			x = 0
			y = y + 0.5
		end
	end
	if x > 0 then y = y + 0.5 end

	table_insert(t, 1, "size[12," .. 5.5 + y .. "]")

	if content then
		t[#t + 1] = "textarea[0.5," .. (y + 0.25) .. ";11,5.5;;;"
		if type(content) == "function" then content = content(player) end
		for i = 1, #content do t[#t + 1] = fse(nct(content[i]) .. "\n") end
		t[#t + 1] = "]"
	end

	return table_concat(t)
end

minetest.register_on_joinplayer(function(player)
		player:set_inventory_formspec(nodecore.inventory_formspec(player))
	end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
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
