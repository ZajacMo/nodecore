-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local pending

local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	if not def.action_delay then return oldreg(def, ...) end

	local oldact = def.action
	function def.action(pos, node)
		if not pending then
			pending = {}
			minetest.after(0, function()
					for i = 1, #pending do
						(pending[i])()
					end
					pending = nil
				end)
		end
		pending[#pending + 1] = function()
			local nn = minetest.get_node(pos)
			if nn.name == node.name then
				return oldact(pos, node)
			end
		end
	end

	return oldreg(def, ...)
end
