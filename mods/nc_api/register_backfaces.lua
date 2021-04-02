-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, type
    = minetest, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local oldreg = minetest.register_item
function minetest.register_item(name, def, ...)
	if def.backface_culling == nil or not def.tiles then
		return oldreg(name, def, ...)
	end
	local t = {}
	for k, v in pairs(def.tiles) do
		t[k] = (type(v) == "string") and {
			name = v,
			backface_culling = def.backface_culling
		} or v
	end
	def.tiles = t
	return oldreg(name, def, ...)
end
