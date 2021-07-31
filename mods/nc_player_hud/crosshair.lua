-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local default_range = 4

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
			quick = true
		})
end

nodecore.register_playerstep({
		label = "crosshair",
		action = function(player)
			if not nodecore.interact(player) then
				return crosshair(player)
			end
			local pos = player:get_pos()
			pos.y = pos.y + player:get_properties().eye_height
			local look = player:get_look_dir()
			local wield = minetest.registered_items[player:get_wielded_item():get_name()]
			local range = wield and wield.range or default_range
			local target = vector.add(pos, vector.multiply(look, range))
			for pt in minetest.raycast(pos, target, true, false) do
				if pt.type == "node" then
					return crosshair(player, "crosshair.png")
				elseif pt.type == "object" then
					return crosshair(player, "object_crosshair.png")
				end
			end
			return crosshair(player, "crosshair.png", true)
		end
	})
