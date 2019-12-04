-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_limited_abm({
		label = "Door Laser Ablation",
		interval = 2,
		chance = 1,
		nodenames = {"nc_optics:lens_on"},
		action = function(pos, node)
			local face = nodecore.facedirs[node.param2]
			local out = vector.add(face.k, pos)
			local tn = minetest.get_node(out)
			nodecore.operate_door(out, tn, face.k)
		end
	})
