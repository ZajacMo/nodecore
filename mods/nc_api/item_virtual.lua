-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local function isvirtual(item)
	return (ItemStack(item):get_definition() or {}).virtual_item
end
nodecore.item_is_virtual = isvirtual

local function guard(func)
	return function(pos, item, ...)
		if not item then return func(pos, item, ...) end
		if isvirtual(item) then return end
		return func(pos, item, ...)
	end
end
minetest.spawn_item = guard(minetest.spawn_item)
minetest.add_item = guard(minetest.add_item)
