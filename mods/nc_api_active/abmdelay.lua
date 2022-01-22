-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	if not def.action_delay then return oldreg(def, ...) end

	local oldact = def.action
	function def.action(pos, node, ...)
		minetest.after(0, function(...)
				local nn = minetest.get_node(pos)
				if nn.name == node.name then
					return oldact(pos, node, ...)
				end
				end, ...)
		end

		return oldreg(def, ...)
	end
