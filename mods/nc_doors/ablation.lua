-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, rawset, vector
    = minetest, nodecore, pairs, rawset, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local dntname = modname .. ":ablation"
local lenson = "nc_optics:lens_on"

local hash = minetest.hash_node_position
local cooldowns = {}

local function ablation(pos, node)
	local key = hash(pos)
	local cooldown = cooldowns[key] or 0
	if cooldown > nodecore.gametime then return end
	cooldowns[key] = nodecore.gametime + 2

	local face = nodecore.facedirs[node.param2]
	local out = vector.add(face.k, pos)
	local tn = minetest.get_node(out)
	if nodecore.operate_door(out, tn, face.k) then
		local ppos = vector.add(vector.multiply(face.k, 0.5), pos)
		local vel = vector.multiply(face.f, 0.5)
		local dvel = {
			x = vel.x ~= 0 and 0.5 or 2,
			y = vel.y ~= 0 and 0.5 or 2,
			z = vel.z ~= 0 and 0.5 or 2,
		}
		minetest.add_particlespawner({
				time = 0.05,
				amount = 30,
				minpos = ppos,
				maxpos = ppos,
				minvel = vector.add(vel, vector.multiply(dvel, -1)),
				maxvel = vector.add(vel, dvel),
				texture = "[combine:1x1^[noalpha^[invert:rgb^[multiply:#808080",
				minsize = 0.25,
				maxsize = 1,
				minexptime = 0.25,
				maxexptime = 0.5
			})
		nodecore.witness(pos, "door ablation")
		return nodecore.dnt_set(pos, dntname, 2)
	end
end

nodecore.register_dnt({
		name = dntname,
		nodenames = {lenson},
		time = 2,
		action = ablation
	})

nodecore.register_limited_abm({
		label = "door ablation",
		interval = 2,
		chance = 1,
		nodenames = {lenson},
		neighbors = {"group:door"},
		action = function(pos)
			return nodecore.dnt_set(pos, dntname, 2)
		end
	})

local function doortrigger(doorpos)
	for _, dir in pairs(nodecore.dirs()) do
		local lenspos = vector.add(doorpos, dir)
		local lensnode = minetest.get_node(lenspos)
		if lensnode.name == lenson then
			local face = nodecore.facedirs[lensnode.param2]
			local out = vector.add(face.k, lenspos)
			if vector.equals(doorpos, out) then
				return ablation(lenspos, minetest.get_node(lenspos))
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
