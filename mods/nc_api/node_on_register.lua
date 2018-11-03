-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore
    = ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.registered_on_register_node = {}
local oldreg = minetest.register_node
function minetest.register_node(name, def, ...)
	for _, v in ipairs(nodecore.registered_on_register_node) do
		local x = v(name, def, ...)
		if x then return x end
	end
	return oldreg(name, def, ...)
end
function nodecore.register_on_register_node(func)
	local t = nodecore.registered_on_register_node
	t[#t + 1] = func
end
