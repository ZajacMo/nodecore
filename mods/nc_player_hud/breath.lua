-- LUALOCALS < ---------------------------------------------------------
local math, nodecore
    = math, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local w = 640
local h = 360
local breath_txr = "[combine:" .. w .. "x" .. h
for y = 0, h - 1, 80 do
	for x = 0, w - 1, 80 do
		breath_txr = breath_txr .. ":" .. x .. "," .. y .. "=nc_player_hud_breath_texture.png"
	end
end
local breath_mask = "^[mask:nc_player_hud_breath_mask.png\\^[resize\\:" .. w .. "x" .. h

nodecore.register_playerstep({
		label = "breath hud",
		priority = -1000,
		action = function(player)
			local br = player:get_breath()
			nodecore.player_discover(player, "breath_" .. br)
			local img = ""
			local o = 255 * (1 - br / 11)
			if o > 0 then
				img = breath_txr .. "^[colorize:#000000:" .. math_floor(255 - o)
				.. breath_mask .. "^[opacity:" .. math_floor(o)
			end
			nodecore.hud_set(player, {
					label = "breath",
					hud_elem_type = "image",
					position = {x = 0.5, y = 0.5},
					text = img,
					direction = 0,
					scale = {x = -100, y = -100},
					offset = {x = 0, y = 0},
					quick = true
				})
		end
	})
