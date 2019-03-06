-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, table, type
    = ipairs, minetest, nodecore, table, type
local table_concat, table_insert
    = table.concat, table.insert
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_inventory_tab,
nodecore.registered_inventory_tabs
= nodecore.mkreg()

do
	local version = nodecore.version
	version = version and ("Version " .. version) or "DEVELOPMENT VERSION"

	nodecore.register_inventory_tab({
			title = "About",
			content = {
				"NodeCore - " .. version,
				"",
				"(C)2018-2019 by Aaron Suen <warr1024@gmail.com>",
				"MIT License:  http://www.opensource.org/licenses/MIT",
				"See include LICENSE file for full details and credits",
				"",
				"https://content.minetest.net/packages/Warr1024/nodecore/",
				"GitLab:    https://gitlab.com/sztest/nodecore",
				"Discord:   https://discord.gg/SHq2tkb"
			}
		})
end

nodecore.register_inventory_tab({
		title = "Inventory",
		content = {
			"Player's Guide: Inventory Management",
			"",
			"- There is NO inventory screen.",
			"- Drop items onto ground to create stack nodes.  They do not decay.",
			"- Sneak+drop to count out single items from stack.",
			"- Sneak+dig stacks to try to keep them separate in hotbar.",
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
		.. ";2.2,0.5;tab;" .. fse(v.title) .. "]"
		if curtab == v.title or (not curtab and i == 1) then
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
		t[#t + 1] = "label[0," .. (y + 0.25) .. ";"
		.. fse(table_concat(f, "\n")) .. "]"
	end

	return table_concat(t)
end

minetest.register_on_joinplayer(function(player)
		player:set_inventory_formspec(nodecore.inventory_formspec(player))
	end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname == "" and fields.tab then
			minetest.show_formspec(player:get_player_name(), formname,
				nodecore.inventory_formspec(player, fields.tab))
		end
	end)
