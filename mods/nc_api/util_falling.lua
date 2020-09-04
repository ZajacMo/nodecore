-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local queue

function nodecore.fallcheck(pos)
	if not queue then
		queue = {}
		minetest.after(0, function()
				for _, p in pairs(queue) do
					minetest.check_for_falling(p)
				end
				queue = nil
			end)
	end
	pos = vector.round(pos)
	queue[minetest.hash_node_position(pos)] = pos
end
