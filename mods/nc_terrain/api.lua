-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor, math_sqrt
    = math.floor, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.hard_stone_strata = 7

function nodecore.hard_stone_tile(n)
	local o = math_floor(math_sqrt(n or 0) * 96)
	if o <= 0 then
		return modname .. "_stone.png"
	end
	if o >= 255 then
		return modname .. "_stone.png^"
		.. modname .. "_stone_hard.png"
	end
	return modname .. "_stone.png^("
	.. modname .. "_stone_hard.png^[opacity:"
	.. o .. ")"
end
