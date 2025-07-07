-- LUALOCALS < ---------------------------------------------------------
local nc, vector
    = nc, vector
-- LUALOCALS > ---------------------------------------------------------

local longjump_cooldown = 4
local longjump_minspeed = 1.3

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
			if longjump.cooldown <= nodecore.gametime then
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
				if ctl.sneak and not ctl.jump then
					longjump.ready = true
				elseif longjump.ready and ctl.jump
					and player:get_velocity().y > 0 then
						longjump.ready = nil
						longjump.cooldown = nodecore.gametime + longjump_cooldown
						local dir = player:get_look_dir()
						dir.y = 0
						dir = vector.normalize(dir)
						player:add_velocity(vector.multiply(dir, 8 * longjump.maxspeed))
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
								maxpos = vector.new(1, 3, 8 * longjump.maxspeed),
								velocity = vector.new(0, 0, -10 * longjump.maxspeed)
							})
						-- force reset run speed
						data.autoruntime = nodecore.gametime
					end
				end
			end
		})
