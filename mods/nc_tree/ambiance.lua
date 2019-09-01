-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local function range(x, min, max)
	if x < min then return min end
	if x > max then return max end
	return x
end

nodecore.register_ambiance({
		label = "Tree Leaves Ambiance",
		nodenames = {"nc_tree:leaves"},
		neigbors = {"air"},
		interval = 1,
		chance = 100,
		sound_name = "nc_tree_windy",
		check = function(pos)
			pos.y = pos.y + 1
			return minetest.get_node(pos).name == "air"
			and minetest.get_node_light(pos, 0.5) == 15
			and {gain = math_sqrt(range(pos.y, 0, 512)) / 20 }
		end
	})
