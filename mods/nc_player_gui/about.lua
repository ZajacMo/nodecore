-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local nct = nodecore.translate

local version = nodecore.version
version = version and (nct("Version") .. " " .. version)
or nct("DEVELOPMENT VERSION")

nodecore.register_inventory_tab({
		title = "About",
		content = {
			nct(nodecore.product) .. " - " .. version,
			"",
			"(C)2018-2021 by Aaron Suen <warr1024@@gmail.com>",
			"MIT License (http://www.opensource.org/licenses/MIT)",
			"See included LICENSE file for full details and credits",
			"",
			"https://content.minetest.net/packages/Warr1024/nodecore/",
			"GitLab: https://gitlab.com/sztest/nodecore",
			"Discord: https://discord.gg/NNYeF6f",
			"IRC: #nodecore @@ chat.freenode.net"
		}
	})
