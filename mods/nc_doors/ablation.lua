-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, vector
    = core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local dntname = modname .. ":ablation"

local hash = core.pos_to_string
local cooldowns = {}

local quick_doors = nc.group_expand("group:door", true)

local function ablation(pos, node)
	local key = hash(pos)
	local cooldown = cooldowns[key] or 0
	if cooldown > nc.gametime then
		local delay = cooldown - nc.gametime
		if delay < 0.001 then delay = 0.001 end
		return nc.dnt_set(pos, dntname, delay)
	end
	cooldowns[key] = nc.gametime + 2

	local face = nc.facedirs[node.param2]
	local out = vector.add(face.k, pos)
	local tn = core.get_node(out)
	if not quick_doors[tn.name] then return end
	if nc.operate_door(out, tn, face.k) then
		local ppos = vector.add(vector.multiply(face.k, 0.5), pos)
		local vel = vector.multiply(face.f, 0.5)
		local dvel = {
			x = vel.x ~= 0 and 0.5 or 2,
			y = vel.y ~= 0 and 0.5 or 2,
			z = vel.z ~= 0 and 0.5 or 2,
		}
		core.add_particlespawner({
				time = 0.05,
				amount = 30,
				minpos = ppos,
				maxpos = ppos,
				minvel = vector.add(vel, vector.multiply(dvel, -1)),
				maxvel = vector.add(vel, dvel),
				texture = "nc_doors_ablation_particle.png",
				minsize = 0.25,
				maxsize = 1,
				minexptime = 0.25,
				maxexptime = 0.5
			})
		nc.witness({pos, out}, "door ablation")
		return nc.dnt_set(pos, dntname)
	end
end

nc.register_on_nodeupdate({
		ignore = {
			stack_set = true,
			remove_node = true,
			dig_node = true,
			add_node_level = true,
			liquid_transformed = true,
		},
		func = function(pos)
			local key = hash(pos)
			local cd = cooldowns[key]
			if cd and cd > nc.gametime + 1 then
				cooldowns[key] = nc.gametime + 1
			end
		end
	})

nc.register_dnt({
		name = dntname,
		nodenames = {"group:optic_lens_emit"},
		time = 2,
		autostart = true,
		autostart_time = 0,
		action = ablation
	})

local function doortrigger(doorpos, _, _, _, defer)
	for _, dir in pairs(nc.dirs()) do
		local lenspos = vector.add(doorpos, dir)
		local lensnode = core.get_node(lenspos)
		if core.get_item_group(lensnode.name, "optic_lens_emit") > 0 then
			local face = nc.facedirs[lensnode.param2]
			local out = vector.add(face.k, lenspos)
			if vector.equals(doorpos, out) then
				defer(function()
						return ablation(lenspos,
							core.get_node(lenspos))
					end)
			end
		end
	end
end

nc.register_on_register_item({
		retroactive = true,
		func = function(_, def)
			if def.groups and def.groups.door and def.groups.door > 0 then
				def.optic_check = doortrigger
				def.groups.optic_check = 1
			end
		end
	})
