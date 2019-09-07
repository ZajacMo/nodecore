-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, table, type
    = ipairs, minetest, nodecore, pairs, table, type
local table_concat, table_insert
    = table.concat, table.insert
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

nodecore.register_inventory_tab,
nodecore.registered_inventory_tabs
= nodecore.mkreg()

local nct = nodecore.translate

do
	local version = nodecore.version
	version = version and (nct("Version") .. " " .. version)
	or nct("DEVELOPMENT VERSION")

	nodecore.register_inventory_tab({
			title = "About",
			content = {
				nct(nodecore.product) .. " - " .. version,
				"",
				"(C)2018-2019 by Aaron Suen <warr1024@@gmail.com>",
				"MIT License (http://www.opensource.org/licenses/MIT)",
				"See included LICENSE file for full details and credits",
				"",
				"https://content.minetest.net/packages/Warr1024/nodecore/",
				"GitLab: https://gitlab.com/sztest/nodecore",
				"Discord: https://discord.gg/SHq2tkb"
			}
		})
end

nodecore.register_inventory_tab({
		title = "Inventory",
		content = {
			"Player's Guide: Inventory Management",
			"",
			"- There is NO inventory screen.",
			"- Drop items onto ground to create stack nodes. They do not decay.",
			"- Sneak+drop to count out single items from stack.",
			"- Items picked up try to fit into the current selected slot first.",
			"- Crafting is done by building recipes in-world.",
			"- Order and specific face of placement may matter for crafting."
		}
	})

nodecore.register_inventory_tab({
		title = "Pummel",
		content = {
			"Player's Guide: Pummeling Recipes",
			"",
			"- Some recipes require \"pummeling\" a node.",
			"- To pummel, punch a node repeatedly, WITHOUT digging.",
			"- You do not have to punch very fast (about 1 per second).",
			"- Recipes are time-based, punching faster does not speed up.",
			"- Wielded item, target face, and surrounding nodes may matter.",
			"- Stacks may be pummeled, exact item count may matter.",
			"- If a recipe exists, you will see a special particle effect."
		}
	})

nodecore.register_inventory_tab({
		title = "Tips",
		content = {
			"Player's Guide: Tips and Guidance",
			"",
			"- Stuck in a pit? Pummel surfaces barehanded to find places to climb.",
			"- Can't dig trees or grass? Search for sticks in the canopy.",
			"- Ores may be hidden, but revealed by subtle clues in terrain.",
			"- \"Torches\" are not a thing; use fire as your first light source.",
			"- \"Furnaces\" are not a thing; discover smelting with open flames.",
			"- Trouble lighting a fire? Try using longer sticks, more tinder.",
			"- The game is challenging by design, sometimes frustrating. DON'T GIVE UP!"
		}
	})

for _, v in pairs(nodecore.registered_inventory_tabs) do
	nct(v.title)
	for i = 1, #v.content do nct(v.content[i]) end
end

local pad = " "
for _ = 1, 8 do pad = pad .. pad end

local fse = minetest.formspec_escape
function nodecore.inventory_formspec(player, curtab)
	local t = {
		"bgcolor[#000000C0;true]",
		"listcolors[#00000000;#00000000;#00000000;#000000FF;#FFFFFFFF]"
	}

	local x = 0
	local y = 0
	local f
	for i, v in ipairs(nodecore.registered_inventory_tabs) do
		t[#t + 1] = "button[" .. x .. "," .. y
		.. ";2.2,0.5;tab" .. i .. ";" .. fse(nct(v.title)) .. "]"
		if curtab == i or (not curtab and i == 1) then
			f = v.content
		end
		x = x + 2
		if x >= 12 then
			x = 0
			y = y + 0.5
		end
	end
	if x > 0 then y = y + 0.5 end

	table_insert(t, 1, "size[12," .. 5.5 + y .. "]")

	if f then
		if type(f) == "function" then f = f(player) end
		for i = 1, #f do
			t[#t + 1] = "label[0," .. (y + 0.25) .. ";"
			.. fse(nct(f[i])) .. pad .. ".]"
			y = y + 0.4
		end
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
