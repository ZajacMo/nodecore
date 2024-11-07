-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc
    = ItemStack, core, nc
-- LUALOCALS > ---------------------------------------------------------

local function isvirtual(item)
	return (ItemStack(item):get_definition() or {}).virtual_item
end
nc.item_is_virtual = isvirtual

local function guard(func)
	return function(pos, item, ...)
		if not item then return func(pos, item, ...) end
		if isvirtual(item) then return end
		return func(pos, item, ...)
	end
end
core.spawn_item = guard(core.spawn_item)
core.add_item = guard(core.add_item)
