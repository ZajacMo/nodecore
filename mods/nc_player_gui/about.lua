-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, string, tonumber
    = core, ipairs, math, nc, string, tonumber
local math_floor, string_sub
    = math.floor, string.sub
-- LUALOCALS > ---------------------------------------------------------

local nct = nc.translate

local version = nc.version
version = version and (nct("Version") .. " " .. version)
or nct("DEVELOPMENT VERSION")

local year = nc.releasedate
year = year and tonumber(string_sub(year, 1, 4))
if (not year) or (year < 2023) then year = 2023 end

local srclang = "en"
local function transstat(lang)
	local qty = nc.translated_stats[lang] or 0
	return nct("~ @1% translated to your language (@2)",
		math_floor(qty / nc.translated_stats[srclang] * 100),
		lang)
end
local transstat_src = transstat(srclang)

local about = {
	nct(nc.product) .. " - " .. version,
	"",
	nct("(C)2018-@1 by Aaron Suen <warr1024@@gmail.com>", year),
	"MIT License (http://www.opensource.org/licenses/MIT)",
	"See included LICENSE file for full details and credits",
	"",
	"https://content.minetest.net/packages/Warr1024/nodecore/",
	"GitLab: https://gitlab.com/sztest/nodecore",
	"",
	"https://hosted.weblate.org/projects/minetest/nodecore/",
	transstat_src,
	"",
	"Discord: https://discord.gg/NNYeF6f",
	"Matrix: #+nodecore:matrix.org",
	"IRC: #nodecore @@ irc.libera.chat",
	"",
	"Donate: https://liberapay.com/NodeCore",
}
for i, v in ipairs(about) do about[i] = nct(v) end

local modfmt = "Additional Mods Loaded: @1"
nc.translate_inform(modfmt)
core.after(0, function()
		local mods = nc.added_mods_list
		if #mods > 0 then
			about[#about + 1] = ""
			about[#about + 1] = nc.translate(modfmt, mods)
		end
	end)

nc.register_inventory_tab({
		title = "About",
		content = function(player)
			local info = core.get_player_information(player:get_player_name())
			local lang = info.lang_code or srclang
			if lang == "" then lang = srclang end
			local lines = {}
			for i = 1, #about do
				local v = about[i]
				if v == transstat_src then
					lines[i] = transstat(lang)
				else
					lines[i] = v
				end
			end
			return lines
		end
	})
