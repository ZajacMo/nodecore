-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

function nodecore.buildable_to(thing)
	if not thing.name then
		thing = nodecore.underride(thing, minetest.get_node(thing))
	end
	if thing.name == "ignore" then return end
	local def = minetest.registered_items[thing.name] or {}
	return def.buildable_to
end
