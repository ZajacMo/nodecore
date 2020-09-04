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

local airpass_drawtypes = {
	airlike = true,
	torchlike = true,
	signlike = true,
	firelike = true,
	fencelike = true,
	raillike = true,
	nodebox = true,
	mesh = true,
	plantlike = true
}
function nodecore.air_pass(thing)
	local name = type(thing) == "string" and thing or thing.name
	or minetest.get_node(thing).name
	local def = minetest.registered_items[name] or {}
	if def.air_pass ~= nil then return def.air_pass end
	return airpass_drawtypes[def.drawtype or false] or false
end
