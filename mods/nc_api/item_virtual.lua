-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, setmetatable
    = ItemStack, minetest, nodecore, setmetatable
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

local bii = minetest.registered_entities["__builtin:item"]
local newbii = {
	on_activate = function(self, ...)
		bii.on_activate(self, ...)
		if isvirtual(self.itemstring) then return self.object:remove() end
	end
}
setmetatable(newbii, bii)
minetest.register_entity(":__builtin:item", newbii)
