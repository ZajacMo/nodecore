-- LUALOCALS < ---------------------------------------------------------
local dofile, pairs, string, table
    = dofile, pairs, string, table
local string_format, table_concat, table_sort
    = string.format, table.concat, table.sort
-- LUALOCALS > ---------------------------------------------------------

-- luacheck: push
-- luacheck: globals config readtext readbinary

readtext = readtext or function() end
readbinary = readbinary or function() end

local alpha = config and config.branch == "dev"

local tags = {
	"building",
	"crafting",
	"education",
	"environment",
	"inventory",
	"oneofakind__original",
	"player_effects",
	"puzzle",
	"pve",
	"technology"
}

local screenshots = {readbinary(alpha and '.cdb-alpha.webp' or '.cdb-release.webp')}
for i = 1, 5 do
	screenshots[#screenshots + 1] = readbinary('.cdb-screen' .. i .. '.webp')
end

local version = dofile("./mods/nc_api/version.lua")
local pkgmeta = dofile("./mods/nc_api/pkgmeta.lua")

local weblate = "https://hosted.weblate.org/projects/minetest/nodecore/"
local transtext = {}
local translated = dofile("./mods/nc_api/translated.lua")
local langs = dofile("./.cdb-langs.lua")
for k, v in pairs(translated) do
	if k ~= "en" then
		local n = langs[k]
		n = n and (n.l or n.en) or k
		transtext[#transtext + 1] = v == translated.en
		and string_format("[%s](%s%s/)✔", n, weblate, k)
		or string_format("[%s](%s%s/)(%d%%)",
			n, weblate, k, v / translated.en * 100)
	end
end
table_sort(transtext)
transtext = "\n\n" .. table_concat(transtext, " — ")

return {
	pkg = alpha and "nodecore_alpha" or "nodecore",
	version = version,
	type = "game",
	title = pkgmeta.title(alpha),
	short_description = pkgmeta.desc(alpha),
	dev_state = alpha and "BETA" or "ACTIVELY_DEVELOPED",
	tags = tags,
	content_warnings = {},
	license = "MIT",
	media_license = "MIT",
	long_description = readtext('.cdb-header.md') .. "\n\n"
	.. (alpha and readtext('.cdb-alpha.md') or readtext('.cdb-release.md'))
	.. "\n\n" .. readtext('.cdb-footer.md') .. transtext,
	repo = "https://gitlab.com/sztest/nodecore",
	website = "https://nodecore.mine.nu",
	issue_tracker = "https://discord.gg/NNYeF6f",
	donate_url = "https://liberapay.com/NodeCore",
	forums = 24857,
	maintainers = {"Warr1024"},
	screenshots = screenshots
}

-- luacheck: pop
