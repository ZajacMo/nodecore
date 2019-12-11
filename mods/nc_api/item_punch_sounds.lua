-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local lasthit = {}

minetest.register_on_punchnode(function(pos, node, puncher)
		if not nodecore.player_visible(puncher) then return end

		local pname = puncher:get_player_name()
		local now = minetest.get_us_time() / 1000000
		local last = lasthit[pname] or 0
		if now - last < 0.25 then return end
		lasthit[pname] = now

		local def = minetest.registered_items[node.name] or {}
		local wield = puncher:get_wielded_item()
		if (not def.sounds) or (not def.groups)
		or (not nodecore.toolspeed(wield, def.groups)) then
			nodecore.node_sound(pos, "dig")
		else
			nodecore.node_sound(pos, "dig",
				{except = puncher})
		end

		if wield:get_wear() >= (65536 * 0.95) then
			minetest.sound_play("nc_api_toolwear",
				{object = puncher, gain = 0.5})
		end
	end)

minetest.register_on_dignode(function(pos, node, digger)
		if not nodecore.player_visible(digger) then return end
		return nodecore.node_sound(pos, "dug",
			{node = node, except = digger})
	end)

minetest.register_on_placenode(function(pos, node, placer)
		if not nodecore.player_visible(placer) then return end
		return nodecore.node_sound(pos, "place",
			{node = node, except = placer})
	end)
