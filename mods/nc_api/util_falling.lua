-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, vector
    = core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local queue

function nc.fallcheck(pos)
	if not queue then
		queue = {}
		core.after(0, function()
				for _, p in pairs(queue) do
					core.check_for_falling(p)
				end
				queue = nil
			end)
	end
	pos = vector.round(pos)
	queue[core.hash_node_position(pos)] = pos
end

function nc.fall_force(pos, node, spawnat)
	nc.node_sound(pos, "fall")
	node = node or core.get_node(pos)
	core.spawn_falling_node(spawnat or pos, node, core.get_meta(pos))
	core.remove_node(pos)
	return nc.fallcheck(vector.offset(pos, 0, 1, 0))
end
