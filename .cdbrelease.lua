-- LUALOCALS < ---------------------------------------------------------
local dofile
    = dofile
-- LUALOCALS > ---------------------------------------------------------

-- luacheck: push
-- luacheck: globals config slurp

local alpha = config and config.branch == "dev"
slurp = slurp or function() end

return {
	user = "Warr1024",
	pkg = "nodecore",
	min = "5.0",
	version = dofile("./mods/nc_api/version.lua"),
	path = ".",
	type = "game",
	title = "NodeCore" .. (alpha and " ALPHA" or ""),
	short_desc = (alpha
		and "Experimental early-access releases of NodeCore."
		or "An original, immersive puzzle/adventure game with NO popup GUIs, minimal HUDs."),
	tags = "building, crafting, environment, inventory, machines, puzzle",
	license = "mit",
	desc = alpha and slurp('.cdb-alpha.md') or slurp('.cdb-release.md'),
	repo = "https://gitlab.com/sztest/nodecore",
	website = "https://nodecore.mine.nu",
	issueTracker = "https://discord.gg/NNYeF6f",
}

-- luacheck: pop
