-- LUALOCALS < ---------------------------------------------------------
local nc, vector
    = nc, vector
-- LUALOCALS > ---------------------------------------------------------

local hijump_cooldown = 1
local hijump_amount = vector.new(0, 5, 0)

nc.register_playerstep({
		label = "hijump",
		action = function(player, data)
			local hijump = data.hijump
			if not hijump then
				hijump = {cooldown = 0}
				data.hijump = hijump
			end

			if hijump.cooldown > nodecore.gametime then return end

			local vel = player:get_velocity()
			if vel.y <= 0 then return end

			local ctl = data.control
			if ctl.sneak then
				if ctl.jump then hijump.ready = true end
				return
			end

			if not hijump.ready then return end
			hijump.ready = nil
			if ctl.jump then return end

			hijump.cooldown = nodecore.gametime + hijump_cooldown
			player:add_velocity(hijump_amount)
			minetest.add_particlespawner({
					amount = 25,
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
					minpos = vector.new(-0.5, 0, -0.5),
					maxpos = vector.new(0.5, 2, 0.5),
					velocity = vector.multiply(hijump_amount, -3)
				})
		end
	})
