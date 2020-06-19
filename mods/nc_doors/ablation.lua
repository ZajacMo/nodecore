-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local dntname = modname .. ":ablation"

local function ablation(pos)
	minetest.log(minetest.pos_to_string(pos))
	local node = minetest.get_node(pos)
	local face = nodecore.facedirs[node.param2]
	local out = vector.add(face.k, pos)
	local tn = minetest.get_node(out)
	if nodecore.operate_door(out, tn, face.k) then
		nodecore.witness(pos, "door ablation")
		nodecore.dnt_set(pos, dntname, 2)
	end
end

nodecore.register_dnt({
		name = dntname,
		action = ablation
	})

nodecore.register_limited_abm({
		label = "door ablation",
		interval = 2,
		chance = 1,
		nodenames = {"nc_optics:lens_on"},
		neighbors = {"group:door"},
		action = function(pos)
			nodecore.dnt_set(pos, dntname, 2)
		end
	})
