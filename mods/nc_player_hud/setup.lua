-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hotbar_slots = 8

local bar_scale = 32
nodecore.register_playerstep({
		label = "hotbar images",
		action = function(player, data)
			local bar = "[combine:" .. (hotbar_slots * bar_scale) .. "x" .. bar_scale
			local inv = player:get_inventory()
			for i = 1, hotbar_slots do
				local stack = inv:get_stack("main", i)
				local def = stack and (not stack:is_empty()) and stack:get_definition()
				local suff = (i == player:get_wield_index()) and "_sel" or "_bar"
				if def and def.hotbar_type then
					suff = suff .. "_" .. def.hotbar_type
				end
				bar = bar .. ":" .. (i * bar_scale - bar_scale) .. ",0="
				.. modname .. suff .. ".png\\^[resize\\:" .. bar_scale
				.. "x" .. bar_scale
			end

			if data.hotbar ~= bar then
				data.hotbar = bar
				player:hud_set_hotbar_image(bar)
			end
		end
	})

nodecore.register_on_joinplayer("setup hotbar", function(player)
		player:hud_set_hotbar_itemcount(hotbar_slots)
		player:hud_set_hotbar_selected_image("[combine:1x1")
	end)

nodecore.register_playerstep({
		label = "hud flags",
		action = function(player, data)
			local interact = nodecore.interact(player)
			data.hud_flags.wielditem = interact or false
			data.hud_flags.hotbar = interact or false
			data.hud_flags.healthbar = false
			data.hud_flags.breathbar = false
			data.hud_flags.minimap = false
			data.hud_flags.minimap_radar = false
		end
	})

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
		action = function(player)
			local br = player:get_breath()
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
