-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.protection_exempt(pos)
	local node = minetest.get_node(pos)
	return node.name == modname .. ":stack"
end

minetest.after(0, function()
		local prot = minetest.is_protected
		function minetest.is_protected(pos, name, ...)
			if nodecore.protection_exempt(pos, name) then return false end
			return prot(pos, name, ...)
		end
	end)
