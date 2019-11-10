-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function reg(name, vis, climb)
	local def = {
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		groups = {[modname] = 1}
	}
	if vis then
		def.light_source = 1
		def.groups[modname .. "_fx"] = 1
	end
	def.climbable = (not not climb) or nil
	return minetest.register_node(modname .. ":" .. name, def)
end

reg("ceil", true, true)
reg("wall", true, true)
reg("floor", true, false)
reg("hang", false, true)
