-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

nc.register_ambiance({
		label = "tree leaves ambiance",
		nodenames = {"nc_tree:leaves"},
		neigbors = {"air"},
		interval = 1,
		chance = 100,
		sound_name = "nc_tree_breeze",
		check = function(pos)
			pos.y = pos.y + 1
			if pos.y <= 0 then return end
			return core.get_node(pos).name == "air"
			and nc.is_full_sun(pos)
			and {gain = nc.windiness(pos.y) / 20}
		end
	})
