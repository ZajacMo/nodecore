-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs
    = ipairs, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local hash = minetest.hash_node_position

local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	if not def.neighbors_invert then return oldreg(def, ...) end

	local nnames = def.nodenames
	def.nodenames = def.neighbors
	def.neighbors = nnames

	local oldact = def.action

	local queue
	local function process()
		for _, v in pairs(queue) do
			local nnode = minetest.get_node(v.pos)
			if nnode.name == v.node.name then
				oldact(v.pos, nnode)
			end
		end
		queue = nil
	end

	function def.action(pos)
		if not queue then
			queue = {}
			minetest.after(0, process)
		end
		for _, npos in ipairs(nodecore.find_nodes_around(pos, nnames, 1)) do
			queue[hash(pos)] = {
				pos = npos,
				node = minetest.get_node(npos)
			}
		end
	end

	return oldreg(def, ...)
end
