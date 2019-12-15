-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local function defprop(prop)
	return function(thing)
		local name = type(thing) == "string" and thing or thing.name
		or minetest.get_node(thing).name
		if name == "ignore" then return end
		local def = minetest.registered_items[name] or {}
		return def[prop]
	end
end

nodecore.buildable_to = defprop("buildable_to")
nodecore.walkable = defprop("walkable")
nodecore.climbable = defprop("climbable")
nodecore.sunlight_propagates = defprop("sunlight_propagates")
