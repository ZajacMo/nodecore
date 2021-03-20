-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.after(0, function()
		local prot = minetest.is_protected
		function minetest.is_protected(pos, name, ...)
			local node = minetest.get_node(pos)
			if node.name == modname .. ":stack" then return false end
			return prot(pos, name, ...)
		end
	end)
