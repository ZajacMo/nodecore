-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local oldreg = minetest.register_abm
function minetest.register_abm(def)
	if def.arealoaded then
		local dist = def.arealoaded
		local oldact = def.action
		def.action = function(pos, node, ...)
			if nodecore.near_unloaded(pos, node, dist) then return end
			return oldact(pos, node, ...)
		end
	end
	return oldreg(def)
end
