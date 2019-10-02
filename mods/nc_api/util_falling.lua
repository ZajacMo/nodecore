-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
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
	queue[minetest.pos_to_string(pos)] = pos
end
