-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, type
    = ItemStack, core, type
-- LUALOCALS > ---------------------------------------------------------

local old_drop = core.item_drop
function core.item_drop(itemstack, dropper, ...)
	local name = itemstack:get_name()
	local def = core.registered_items[name]
	if not (def and def.drop_as) then
		return old_drop(itemstack, dropper, ...)
	end
	if type(def.drop_as) == "string" then
		itemstack:set_name(def.drop_as)
	elseif type(def.drop_as) == "function" then
		itemstack = ItemStack(def.drop_as(itemstack, dropper, ...))
	end
	return old_drop(itemstack, dropper, ...)
end
