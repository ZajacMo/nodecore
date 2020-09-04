-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
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
				local suff = (i == player:get_wield_index()) and "_sel" or "_slot"
				if def and def.hotbar_type then
					suff = suff .. "_" .. def.hotbar_type
				end
				bar = bar .. ":" .. (i * bar_scale - bar_scale) .. ",0="
				.. modname .. suff .. ".png\\^[resize\\:" .. bar_scale
				.. "x" .. bar_scale
			end

			if data.slots ~= hotbar_slots then
				data.slots = hotbar_slots
				player:hud_set_hotbar_itemcount(hotbar_slots)
			end

			if data.hotbar ~= bar then
				data.hotbar = bar
				player:hud_set_hotbar_image(bar)
			end
		end
	})

nodecore.register_on_joinplayer("setup hotbar", function(player)
		player:hud_set_hotbar_selected_image("[combine:1x1")
	end)
