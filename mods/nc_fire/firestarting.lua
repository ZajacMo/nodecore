-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, math, nc, vector
    = ItemStack, core, math, nc, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local firedirs = {
	{x = 0, y = 1, z = 0},

	{x = 1, y = 0, z = 0},
	{x = 1, y = 0, z = 0},

	{x = -1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},

	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = 1},

	{x = 0, y = 0, z = -1},
	{x = 0, y = 0, z = -1},

	{x = 0, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
}

function nc.firestick_spark_ignite(pos, ignite)
	core.add_particlespawner({
			amount = 50,
			time = 0.02,
			minpos = {x = pos.x, y = pos.y - 0.25, z = pos.z},
			maxpos = {x = pos.x, y = pos.y + 0.5, z = pos.z},
			minvel = {x = -2, y = -3, z = -2},
			maxvel = {x = 2, y = 1, z = 2},
			minacc = {x = 0, y = -0.5, z = 0},
			maxacc = {x = 0, y = -0.5, z = 0},
			minxeptime = 0.4,
			maxexptime = 0.5,
			minsize = 0.4,
			maxsize = 0.5,
			texture = "nc_fire_spark.png",
			collisiondetection = true,
			glow = 7
		})

	if not ignite then return end
	local dir = firedirs[math_random(1, #firedirs)]
	return nc.fire_check_ignite(vector.add(pos, dir))
end

nc.register_craft({
		label = "stick fire starting",
		action = "pummel",
		wield = {
			groups = {firestick = true}
		},
		indexkeys = {"group:firestick"},
		nodes = {
			{match = {groups = {firestick = true}}}
		},
		consumewield = 1,
		duration = 5,
		check = function() return not nc.fire_quell end,
		before = function(pos, data)
			local fs = core.get_item_group(data.node.name, "firestick")
			* core.get_item_group(ItemStack(data.wield):get_name(), "firestick")

			if math_random(1, 4) > fs then
				nc.smokeburst(pos)
				nc.sound_play("nc_api_toolbreak", {pos = pos, gain = 1})
				return
			end

			nc.fire_ignite(pos)
			return nc.firestick_spark_ignite(pos,
				math_random(1, 4) <= fs)
		end
	})
