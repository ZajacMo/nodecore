-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore
    = ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local hash = minetest.hash_node_position

local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	if not def.neighbors_invert then return oldreg(def, ...) end

	local nnames = def.nodenames
	def.nodenames = def.neighbors
	def.neighbors = nnames

	local oldact = def.action

	local dirty
	local blocked = {}

	function def.action(pos)
		if not dirty then
			dirty = true
			minetest.after(0, function()
					blocked = {}
					dirty = nil
				end)
		end
		for _, npos in ipairs(nodecore.find_nodes_around(pos, nnames, 1)) do
			local key = hash(npos)
			if not blocked[key] then
				blocked[key] = true
				oldact(npos, minetest.get_node(npos))
			end
		end
	end

	return oldreg(def, ...)
end
