-- LUALOCALS < ---------------------------------------------------------
local nodecore
    = nodecore
-- LUALOCALS > ---------------------------------------------------------

local function crosshair(player, img, fade)
	if img then img = img .. "^[opacity:" .. (fade and 32 or 192) end
	nodecore.hud_set(player, {
			label = "crosshair",
			hud_elem_type = "image",
			position = {x = 0.5, y = 0.5},
			text = img,
			direction = 0,
			alignment = {x = 0, y = 0},
			scale = {x = 1, y = 1},
			offset = {x = 0, y = 0},
			z_index = -275,
			quick = true
		})
end

nodecore.register_playerstep({
		label = "crosshair",
		priority = -101,
		action = function(player, data)
			if data.pointing == "node" then
				return crosshair(player, "crosshair.png")
			elseif data.pointing == "obj" then
				return crosshair(player, "object_crosshair.png")
			else
				return crosshair(player, "crosshair.png", true)
			end
		end
	})
