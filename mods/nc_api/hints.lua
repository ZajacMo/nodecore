-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

--[[
hint = {
	name = "...",
	req = { ...matchspec ... },
	pass = { ...matchspec ... },
	text = "..."
}
matchspec = {
	["know:node:name"] = true,
	["have:node:name"] = false,
	...
}
--]]

nodecore.register_hint, nodecore.registered_hints = nodecore.mkreg()

function nodecore.get_hints(player)
end
