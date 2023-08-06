-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string, tonumber
    = minetest, nodecore, string, tonumber
local string_sub
    = string.sub
-- LUALOCALS > ---------------------------------------------------------

local nct = nodecore.translate

local version = nodecore.version
version = version and (nct("Version") .. " " .. version)
or nct("DEVELOPMENT VERSION")

local year = nodecore.releasedate
year = year and tonumber(string_sub(year, 1, 4))
if (not year) or (year < 2023) then year = 2023 end

local about = {
	nct(nodecore.product) .. " - " .. version,
	"",
	nodecore.translate("(C)2018-@1 by Aaron Suen <warr1024@@gmail.com>", year),
	"MIT License (http://www.opensource.org/licenses/MIT)",
	"See included LICENSE file for full details and credits",
	"",
	"https://content.minetest.net/packages/Warr1024/nodecore/",
	"GitLab: https://gitlab.com/sztest/nodecore",
	"",
	"Discord: https://discord.gg/NNYeF6f",
	"Matrix: #+nodecore:matrix.org",
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
