-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, pairs, vector
    = core, ipairs, math, nc, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local sparks_add, sparks_flush = nc.fairlimit(50)

nc.register_globalstep(function()
		for _, pos in ipairs(sparks_flush()) do
			core.after(math_random(), function()
					core.add_particlespawner({
							amount = math_random(1, 3),
							time = 1,
							minpos = vector.subtract(pos, 0.5),
							maxpos = vector.add(pos, 0.5),
							minvel = {x = -1, y = 2, z = -1},
							maxvel = {x = 1, y = 2.5, z = 1},
							minacc = {x = -0.1, y = 0, z = -0.1},
							maxacc = {x = 0.1, y = 0, z = 0.1},
							minxeptime = 1,
							maxexptime = 3,
							minsize = 0.1,
							maxsize = 0.2,
							collisiondetection = true,
							collision_removal = true,
							texture = "nc_fire_spark.png",
							glow = math_random(5, 9)
						})
				end)
		end
	end)

do
	local flamedirs = nc.dirs()
	local embers = {}
	core.after(0, function()
			for k, v in pairs(core.registered_items) do
				if v.groups.ember then
					embers[k] = true
				end
			end
		end)
	core.register_abm({
			label = "fire consume",
			interval = 1,
			chance = 1,
			arealoaded = 1,
			nodenames = {modname .. ":fire"},
			action = function(pos)
				sparks_add(pos)
				local found = {}
				for _, dp in ipairs(flamedirs) do
					local npos = vector.add(pos, dp)
					local node = core.get_node_or_nil(npos)
					if (not node) or embers[node.name] then
						found[#found + 1] = npos
					end
				end
				if #found < 1 then
					return core.remove_node(pos)
				end
				local picked = nc.pickrand(found)
				return nc.fire_check_expend(picked)
			end
		})
end

core.register_abm({
		label = "flammables ignite",
		interval = 5,
		chance = 1,
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		neighbors_invert = true,
		arealoaded = 1,
		action_delay = true,
		action = function(pos)
			nc.fire_check_ignite(pos)
		end
	})

core.register_abm({
		label = "ember snuff/flames",
		interval = 1,
		chance = 1,
		nodenames = {"group:ember"},
		arealoaded = 1,
		action = function(pos, node)
			local snuff, vents = nc.fire_check_snuff(pos, node)
			if snuff or not vents then return end
			for i = 1, #vents do
				if vents[i].q < 1 then
					nc.set_node_check(vents[i], {name = modname .. ":fire"})
				end
			end
		end
	})

nc.register_ambiance({
		label = "flame ambiance",
		nodenames = {"group:flame_ambiance"},
		interval = 1,
		chance = 1,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.2
	})

nc.register_item_ambiance({
		label = "flame ambiance",
		itemnames = {"group:flame_ambiance"},
		interval = 1,
		chance = 1,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})
