-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hotbar_slots = 8

local bar_scale = 32
local bar_margin = 1
nodecore.register_playerstep({
		label = "hotbar images",
		action = function(player, data)
			local bar = "[combine:" .. (hotbar_slots * bar_scale + bar_margin * 2)
			.. "x" .. (bar_scale + bar_margin * 2) .. ":0,0=" .. modname .. "_bar.png"
			local inv = player:get_inventory()
			for i = 1, hotbar_slots do
				local stack = inv:get_stack("main", i)
				local def = stack and (not stack:is_empty()) and stack:get_definition()
				local hbtype = def and def.hotbar_type
				and ("_" .. def.hotbar_type) or ""
				bar = bar .. ":" .. (i * bar_scale - bar_scale + bar_margin)
				.. "," .. bar_margin .. "=" .. modname .. "_slot" .. hbtype
				.. ".png\\^[resize\\:" .. bar_scale .. "x" .. bar_scale
				.. "\\^[opacity\\:192"
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
		player:hud_set_hotbar_selected_image(modname .. "_sel.png")
	end)
