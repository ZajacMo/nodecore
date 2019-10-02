-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_ambiance({
		label = "Tree Leaves Ambiance",
		nodenames = {"nc_tree:leaves"},
		neigbors = {"air"},
		interval = 1,
		chance = 100,
		sound_name = "nc_tree_breeze",
		check = function(pos)
			pos.y = pos.y + 1
			if pos.y <= 0 then return end
			return minetest.get_node(pos).name == "air"
			and minetest.get_node_light(pos, 0.5) == 15
			and { gain = nodecore.windiness(pos.y) / 20 }
		end
	})
