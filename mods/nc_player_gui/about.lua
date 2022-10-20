-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local nct = nodecore.translate

local version = nodecore.version
version = version and (nct("Version") .. " " .. version)
or nct("DEVELOPMENT VERSION")

local about = {
	nct(nodecore.product) .. " - " .. version,
	"",
	"(C)2018-2021 by Aaron Suen <warr1024@@gmail.com>",
	"MIT License (http://www.opensource.org/licenses/MIT)",
	"See included LICENSE file for full details and credits",
	"",
	"https://content.minetest.net/packages/Warr1024/nodecore/",
	"GitLab: https://gitlab.com/sztest/nodecore",
	"",
	"Discord: https://discord.gg/NNYeF6f",
	"Matrix: #nodecore:matrix.org",
	"IRC: #nodecore @@ irc.libera.chat",
	"",
	"Donate: https://liberapay.com/NodeCore",
}

local modfmt = "Additional Mods Loaded: @1"
nodecore.translate_inform(modfmt)
minetest.after(0, function()
		local mods = nodecore.added_mods_list
		if #mods > 0 then
			about[#about + 1] = ""
			about[#about + 1] = nodecore.translate(modfmt, mods)
		end
	end)

nodecore.register_inventory_tab({
		title = "About",
		content = about
	})
