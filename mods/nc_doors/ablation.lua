-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, vector
    = minetest, nodecore, pairs, rawset, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local dntname = modname .. ":ablation"

local function ablation(pos)
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

local lenson = "nc_optics:lens_on"
nodecore.register_limited_abm({
		label = "door ablation",
		interval = 2,
		chance = 1,
		nodenames = {lenson},
		neighbors = {"group:door"},
		action = function(pos)
			nodecore.dnt_set(pos, dntname, 2)
		end
	})

local function doortrigger(pos)
	for _, d in pairs(nodecore.dirs()) do
		local p = vector.add(pos, d)
		local n = minetest.get_node(p)
		if n.name == lenson then
			local face = nodecore.facedirs[n.param2]
			local out = vector.add(face.k, p)
			if vector.equals(pos, out) then
				return ablation(p)
			end
		end
	end
end

minetest.after(0, function()
		for _, v in pairs(minetest.registered_nodes) do
			if v.groups.door and v.groups.door > 0 then
				rawset(v, "optic_check", doortrigger)
			end
		end
	end)
