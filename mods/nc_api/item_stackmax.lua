-- LUALOCALS < ---------------------------------------------------------
local core
    = core
-- LUALOCALS > ---------------------------------------------------------

local function fixmax(def)
	if def.stack_max == 99 then def.stack_max = 100 end
end

fixmax(core.nodedef_default)
fixmax(core.craftitemdef_default)
fixmax(core.tooldef_default)
fixmax(core.noneitemdef_default)
