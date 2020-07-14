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
	user = "Warr1024",
	pkg = alpha and "nodecore_alpha" or "nodecore",
	min = "5.2",
	version = dofile("./mods/nc_api/version.lua"),
	path = ".",
	type = "game",
	title = "NodeCore" .. (alpha and " ALPHA" or ""),
	short_desc = (alpha
		and "Experimental early-access release of NodeCore."
		or "Original, immersive puzzle/adventure game with NO popup GUIs, minimal HUDs."),
	tags = "building, crafting, environment, inventory, machines, player vs env, puzzle",
	license = "mit",
	desc = alpha and readtext('.cdb-alpha.md') or readtext('.cdb-release.md'),
	repo = "https://gitlab.com/sztest/nodecore",
	website = "https://nodecore.mine.nu",
	issueTracker = "https://discord.gg/NNYeF6f",
	forums = "https://forum.minetest.net/viewtopic.php?f=15&t=24857",
	screenshots = alpha
	and {readbinary('.cdb-alpha.jpg'), readbinary('.cdb-release.jpg')}
	or {readbinary('.cdb-release.jpg')}
}

-- luacheck: pop
