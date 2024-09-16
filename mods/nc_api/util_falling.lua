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

function nodecore.fall_force(pos, node, spawnat)
	nodecore.node_sound(pos, "fall")
	node = node or minetest.get_node(pos)
	minetest.spawn_falling_node(spawnat or pos, node, minetest.get_meta(pos))
	minetest.remove_node(pos)
	return nodecore.fallcheck(vector.offset(pos, 0, 1, 0))
end
