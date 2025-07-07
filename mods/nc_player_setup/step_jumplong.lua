-- LUALOCALS < ---------------------------------------------------------
local nc, vector
    = nc, vector
-- LUALOCALS > ---------------------------------------------------------

local longjump_cooldown = 1
local longjump_minvel = 6

nc.register_playerstep({
		label = "longjump",
		action = function(player, data)
			local longjump = data.longjump
			if not longjump then
				longjump = {
					cooldown = 0,
					minveltime = 0,
					maxvel = 0
				}
				data.longjump = longjump
			end
			if longjump.cooldown <= nodecore.gametime then
				local ctl = data.control
				if not ctl.up then
					longjump.minveltime = 0
					longjump.maxvel = 0
					longjump.ready = false
					return
				end
				local vel = player:get_velocity()
				local xzvel = vector.length({x = vel.x, y = 0, z = vel.z})
				if xzvel >= longjump_minvel then
					if xzvel > longjump.maxvel then longjump.maxvel = xzvel end
					longjump.minveltime = nodecore.gametime + longjump_cooldown
				end
				if nodecore.gametime >= longjump.minveltime then return end
				if ctl.sneak and not ctl.jump then
					longjump.ready = true
				elseif ctl.jump and vel.y > 0 then
					longjump.ready = false
					longjump.cooldown = nodecore.gametime + longjump_cooldown
					local dir = player:get_look_dir()
					dir.y = 0
					dir = vector.normalize(dir)
					player:add_velocity(vector.multiply(dir, 3 * longjump.maxvel))
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
							maxpos = vector.new(1, 3, 3 * longjump.maxvel),
							velocity = vector.new(0, 0, -5 * longjump.maxvel)
						})
				end
			end
		end
	})
