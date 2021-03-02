-- LUALOCALS < ---------------------------------------------------------
local minetest, type
    = minetest, type
-- LUALOCALS > ---------------------------------------------------------

if minetest.features.use_texture_alpha_string_modes then return end

local oldreg = minetest.register_item
function minetest.register_item(name, def, ...)
	if def and type(def.use_texture_alpha) == "string" then
		def.use_texture_alpha = def.use_texture_alpha == "blend" or nil
	end
	return oldreg(name, def, ...)
end
