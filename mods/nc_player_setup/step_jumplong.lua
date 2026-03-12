-- LUALOCALS < ---------------------------------------------------------
local core, nc, vector
    = core, nc, vector
-- LUALOCALS > ---------------------------------------------------------

local longjump_strength = 10
local longjump_lift = 2
local longjump_cooldown = 4
local longjump_minspeed = 1.3

local function solid(pos)
	local node = core.get_node(pos)
	local def = core.registered_items[node.name]
	if not def then return true end
	return def.liquidtype == "none" and def.walkable
end

nc.register_playerstep({
		label = "longjump",
		action = function(player, data)
			local longjump = data.longjump
			if not longjump then
				longjump = {
					cooldown = 0,
					minspeedtime = 0,
					maxspeed = 0
				}
				data.longjump = longjump
			end

			if longjump.cooldown > nodecore.gametime then return end

			local ctl = data.control
			if not ctl.up then
				longjump.minspeedtime = 0
				longjump.maxspeed = 0
				longjump.ready = nil
				return
			end

			local speed = data.physics.speed
			if speed >= longjump_minspeed then
				if speed > longjump.maxspeed then longjump.maxspeed = speed end
				longjump.minspeedtime = nodecore.gametime + longjump_cooldown
			end
			if nodecore.gametime >= longjump.minspeedtime then return end

			local pos = player:get_pos()
			local grounded = not solid(pos)
			if grounded then
				pos.y = pos.y - 1
				grounded = solid(pos)
			end
			if not grounded then
				longjump.ready = nil
				return
			end

			if ctl.sneak and not ctl.jump then
				longjump.ready = true
				return
			end

			if not (longjump.ready and ctl.jump and player:get_velocity().y > 0)
			then return end

			longjump.ready = nil
			longjump.cooldown = nodecore.gametime + longjump_cooldown
			local dir = player:get_look_dir()
			dir.y = 0
			dir = vector.normalize(dir)
			local addvel = vector.multiply(dir, longjump_strength * longjump.maxspeed)
			addvel.y = longjump_lift
			player:add_velocity(addvel)
			minetest.add_particlespawner({
					amount = 50,
					time = 0.05,
					size = 1/4,
					minexptime = 0.125,
					maxexptime = 0.25,
					texture = {
						name = "nc_player_setup_particle.png",
						blend = "add",
					},
					playername = player:get_player_name(),
					attached = player,
					glow = 14,
					minpos = vector.new(-1, 1, -1),
					maxpos = vector.new(1, 3, longjump_strength * longjump.maxspeed),
					velocity = vector.new(0, 0, -(longjump_strength + 2) * longjump.maxspeed)
				})
			-- force reset run speed
			data.autoruntime = nodecore.gametime
		end
	})
