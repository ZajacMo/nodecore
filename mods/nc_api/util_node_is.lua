-- LUALOCALS < ---------------------------------------------------------
local core, nc, type
    = core, nc, type
-- LUALOCALS > ---------------------------------------------------------

local function defprop(prop)
	return function(thing)
		local name = type(thing) == "string" and thing or thing.name
		or core.get_node(thing).name
		if name == "ignore" then return end
		local def = core.registered_items[name] or {}
		return def[prop]
	end
end

nc.buildable_to = defprop("buildable_to")
nc.walkable = defprop("walkable")
nc.climbable = defprop("climbable")
nc.sunlight_propagates = defprop("sunlight_propagates")
nc.air_equivalent = defprop("air_equivalent")

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
function nc.air_pass(thing)
	local name = type(thing) == "string" and thing or thing.name
	or core.get_node(thing).name
	local def = core.registered_items[name] or {}
	if def.air_pass ~= nil then return def.air_pass end
	return airpass_drawtypes[def.drawtype or false] or false
end
