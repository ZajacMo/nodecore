-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, table
    = minetest, nodecore, table
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

local version = nodecore.version
version = version and ("Version " .. version) or "DEVELOPMENT VERSION"

local lines = {
	"NodeCore - " .. version,
	"",
	"(C)2018-2019 by Aaron Suen <warr1024@gmail.com>",
	"MIT License:  http://www.opensource.org/licenses/MIT",
	"",
	"GitLab:    https://gitlab.com/sztest/nodecore",
	"Discord:   https://discord.gg/SHq2tkb"
}

nodecore.inventory_formspec = "size[12,5]"
.. "bgcolor[#000000C0;true]"
.. "listcolors[#00000000;#00000000;#00000000;#000000FF;#FFFFFFFF]"
.. "label[0,0;" .. minetest.formspec_escape(table_concat(lines, "\n")) .. "]"

minetest.register_on_joinplayer(function(player)
		player:set_inventory_formspec(nodecore.inventory_formspec)
	end)
