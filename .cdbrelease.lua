-- LUALOCALS < ---------------------------------------------------------
local dofile
    = dofile
-- LUALOCALS > ---------------------------------------------------------

-- luacheck: push
-- luacheck: globals config readtext readbinary

local alpha = config and config.branch == "dev"
readtext = readtext or function() end
readbinary = readbinary or function() end

return {
	pkg = alpha and "nodecore_alpha" or "nodecore",
	version = dofile("./mods/nc_api/version.lua"),
	path = ".",
	title = "NodeCore" .. (alpha and " ALPHA" or ""),
	short_description = (alpha
		and "Experimental early-access release of NodeCore."
		or "Original, immersive puzzle/adventure game with NO popup GUIs, minimal HUDs."),
	long_description = alpha and readtext('.cdb-alpha.md') or readtext('.cdb-release.md'),
	screenshots = (alpha
		and {readbinary('.cdb-alpha.jpg'), readbinary('.cdb-release.jpg')}
		or {readbinary('.cdb-release.jpg')})
}

-- luacheck: pop
