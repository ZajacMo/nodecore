-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore
    = ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item,
nodecore.registered_on_register_item
= nodecore.mkreg()

local oldreg = minetest.register_item
function minetest.register_item(name, def, ...)
	for _, v in ipairs(nodecore.registered_on_register_item) do
		local x = v(name, def, ...)
		if x then return x end
	end
	return oldreg(name, def, ...)
end
