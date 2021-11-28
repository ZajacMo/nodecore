-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, table
    = minetest, nodecore, pairs, table
local table_concat, table_sort
    = table.concat, table.sort
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
	"IRC: #nodecore @@ irc.libera.chat"
}

local modfmt = "- @1"
nodecore.translate_inform(modfmt)
local mods = {}
for _, n in pairs(minetest.get_modnames()) do
	if not nodecore.coremods[n] then
		mods[#mods + 1] = n
	end
end
table_sort(mods)
if #mods > 0 then
	about[#about + 1] = ""
	about[#about + 1] = "Additional Mods Loaded: " .. table_concat(mods, ", ")
end

nodecore.register_inventory_tab({
		title = "About",
		content = about
	})
