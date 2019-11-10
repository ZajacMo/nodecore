-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function reg(name, climb, light, fx, lv)
	local def = {
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		climbable = climb and true or nil,
		light_source = light or nil,
		groups = {
			[modname] = lv,
			[modname .. "_fx"] = fx and 1 or nil
		}
	}
	return minetest.register_node(modname .. ":" .. name, def)
end

reg("ceil", true, 1, true, 4)
reg("wall", true, 1, true, 3)
reg("floor", nil, 1, nil, 2)
reg("hang", true, nil, nil, 1)
