-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local function reg(name, climb, light, fx, lv)
	local def = {
		description = core.registered_nodes.air.description,
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		buildable_to = true,
		floodable = true,
		air_equivalent = true,
		climbable = climb and true or nil,
		light_source = light or nil,
		groups = {
			[modname] = lv,
			[modname .. "_fx"] = fx and 1 or nil
		}
	}
	return core.register_node(modname .. ":" .. name, def)
end

local ll = nc.scaling_light_level
reg("ceil", true, ll, true, 4)
reg("wall", true, ll, true, 3)
reg("floor", nil, ll, nil, 2)
reg("hang", true, nil, nil, 1)
