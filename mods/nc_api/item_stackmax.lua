-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local function fixmax(def)
	if def.stack_max == 99 then def.stack_max = 100 end
end

fixmax(minetest.nodedef_default)
fixmax(minetest.craftitemdef_default)
fixmax(minetest.tooldef_default)
fixmax(minetest.noneitemdef_default)
