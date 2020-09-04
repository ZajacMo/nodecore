-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string
    = minetest, nodecore, string
local string_lower
    = string.lower
-- LUALOCALS > ---------------------------------------------------------

function nodecore.hints_disabled()
	return minetest.settings:get_bool(
		string_lower(nodecore.product) .. "_disable_hints")
end
