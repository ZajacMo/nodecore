-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, vector
    = ItemStack, math, minetest, nodecore, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_craft({
		label = "stick fire starting",
		action = "pummel",
		wield = {
			groups = {firestick = true}
		},
		nodes = {
			{match = {groups = {firestick = true}}}
		},
		consumewield = 1,
		duration = 5,
		before = function(pos, data)
			local w = data.wield and ItemStack(data.wield):get_name() or ""
			local wd = minetest.registered_items[w] or {}
			local wg = wd.groups or {}
			local fs = wg.firestick or 1
			local nd = minetest.registered_items[data.node.name] or {}
			local ng = nd.groups or {}
			fs = fs * (ng.firestick or 1)

			if math_random(1, 4) > fs then return end
			nodecore.fire_ignite(pos)
			minetest.add_particlespawner({
					amount = 25,
					time = 0.02,
					minpos = vector.subtract(pos, 0.25),
					maxpos = vector.add(pos, 0.25),
					minvel = {x = -2, y = 0, z = -2},
					maxvel = {x = 2, y = 0, z = 2},
					minacc = {x = -0.1, y = 0, z = -0.1},
					maxacc = {x = 0.1, y = 0, z = 0.1},
					minxeptime = 0.4,
					maxexptime = 0.5,
					minsize = 0.4,
					maxsize = 0.5,
					texture = "nc_fire_spark.png",
					glow = 7
				})

			if math_random(1, 4) > fs then return end
			local dir = nodecore.pickrand(nodecore.dirs())
			return nodecore.fire_check_ignite({
					x = pos.x + dir.x,
					y = pos.y + dir.y,
					z = pos.z + dir.z
				})
		end
	})
