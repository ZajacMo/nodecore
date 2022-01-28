-- LUALOCALS < ---------------------------------------------------------
local dofile
    = dofile
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

local screenshots = {}
if alpha then screenshots[1] = readbinary('.cdb-alpha.jpg') end
screenshots[#screenshots + 1] = readbinary('.cdb-release.jpg')
for i = 1, 5 do
	screenshots[#screenshots + 1] = readbinary('.cdb-screen' .. i .. '.jpg')
end

return {
	pkg = alpha and "nodecore_alpha" or "nodecore",
	version = dofile("./mods/nc_api/version.lua"),
	type = "game",
	title = "NodeCore" .. (alpha and " ALPHA" or ""),
	short_description = (alpha
		and "Early-access edition of NodeCore with latest features (and maybe bugs)"
		or "Minetest's top original voxel game about emergent mechanics and exploration"),
	dev_state = alpha and "BETA" or "ACTIVELY_DEVELOPED",
	tags = tags,
	content_warnings = {},
	license = "MIT",
	media_license = "MIT",
	long_description = readtext('.cdb-header.md') .. "\n\n"
	.. (alpha and readtext('.cdb-alpha.md') or readtext('.cdb-release.md'))
	.. "\n\n" .. readtext('.cdb-footer.md'),
	repo = "https://gitlab.com/sztest/nodecore",
	website = "https://nodecore.mine.nu",
	issue_tracker = "https://discord.gg/NNYeF6f",
	forums = 24857,
	maintainers = {"Warr1024"},
	screenshots = screenshots
}

-- luacheck: pop
