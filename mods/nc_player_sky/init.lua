-- LUALOCALS < ---------------------------------------------------------
local math, nodecore, pairs
    = math, nodecore, pairs
local math_ceil, math_floor
    = math.ceil, math.floor
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local skyboxes = {}
for dark = 0, 255 do
	local txr = {}
	for i = 1, 6 do
		txr[#txr + 1] = "nc_player_sky_box" .. i
		.. ".png^[colorize:#000000:" .. dark
	end
	local color = {r = 0x50, g = 0x50, b = 0x76}
	for k, v in pairs(color) do
		color[k] = math_floor(0.5 + v * (255 - dark) / 255)
	end
	skyboxes[dark] = {
		base_color = color,
		type = "skybox",
		textures = txr,
		clouds = false
	}
end

nodecore.register_playerstep({
		label = "skybox/sunlight",
		action = function(player, data)
			local depth = math_floor(player:get_pos().y + 0.5)

			local rawdll = nodecore.get_depth_light(depth, 1)
			local dark = 255 - math_ceil(255 * rawdll)
			data.sky = skyboxes[dark]

			data.daynight = nodecore.get_depth_light(depth)
		end
	})

nodecore.register_on_joinplayer("sky setup", function(player)
		for k in pairs({set_sun = true, set_moon = true, set_stars = true}) do
			if player[k] then
				player[k](player, {visible = false, sunrise_visible = false})
			end
		end
	end)
