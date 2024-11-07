-- LUALOCALS < ---------------------------------------------------------
local core
    = core
-- LUALOCALS > ---------------------------------------------------------

local pending

local oldreg = core.register_abm
function core.register_abm(def, ...)
	if not def.action_delay then return oldreg(def, ...) end

	local oldact = def.action
	function def.action(pos, node)
		if not pending then
			pending = {}
			core.after(0, function()
					for i = 1, #pending do
						(pending[i])()
					end
					pending = nil
				end)
		end
		pending[#pending + 1] = function()
			local nn = core.get_node(pos)
			if nn.name == node.name then
				return oldact(pos, node)
			end
		end
	end

	return oldreg(def, ...)
end
