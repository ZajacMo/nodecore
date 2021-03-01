-- LUALOCALS < ---------------------------------------------------------
local math, nodecore, pairs, string, vector
    = math, nodecore, pairs, string, vector
local math_ceil, math_floor, math_log, string_gsub
    = math.ceil, math.floor, math.log, string.gsub
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local skyboxes = {}
for dark = 0, 255 do
	local txr = {}
	for i = 1, 6 do
		txr[#txr + 1] = "nc_player_sky_box" .. i
		.. ".png^[colorize:#000000:" .. dark
	end
	local color = {r = 0x1d, g = 0x21, b = 0x36}
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

local function esc(t) return string_gsub(string_gsub(t, "%^", "\\^"), ":", "\\:") end

local posscale = 128 / math_log(32768)
nodecore.register_playerstep({
		label = "skybox/sunlight",
		action = function(player, data)
			local depth = math_floor(player:get_pos().y + 0.5)

			local rawdll = nodecore.get_depth_light(depth, 1)
			local dark = 255 - math_ceil(255 * rawdll)
			data.sky = {}
			for k, v in pairs(skyboxes[dark]) do
				data.sky[k] = v
			end
			local txr = data.sky.textures
			data.sky.textures = {}
			for k, v in pairs(txr) do
				data.sky.textures[k] = v
			end
			local top = data.sky.textures[1]
			top = "[combine:256x256:0,0=" .. esc("(" .. top .. ")^[resize:256x256")

			local pos = player:get_pos()
			pos.y = 0
			local dist = vector.length(pos)
			local log = math_log(dist + 1) * posscale
			pos = vector.multiply(pos, log / dist)
			local px = pos.z
			local py = -pos.x
			local opac = (px * px + py * py) / 8 - 200
			if opac > 0 then
				if opac > 255 then opac = 255 end
				top = top .. ":" .. (123 + px) .. "," .. (123 + py)
				.. "=" .. esc("nc_player_sky_star.png^[resize:11x11"
					.. "^[opacity:" .. opac)
				data.sky.textures[1] = top
			end

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
