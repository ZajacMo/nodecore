-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local lasthit = {}

local function wearfx(puncher, wield)
	nc.sound_play("nc_api_toolwear",
		{object = puncher, gain = 0.5})
	return nc.toolbreakparticles(puncher, wield:get_definition(), 4)
end

nc.register_on_punchnode(function(pos, node, puncher)
		if not nc.player_visible(puncher) then return end

		local pname = puncher:get_player_name()
		local now = core.get_us_time() / 1000000
		local last = lasthit[pname] or 0
		if now - last < 0.25 then return end
		lasthit[pname] = now

		local def = core.registered_items[node.name] or {}
		local wield = puncher:get_wielded_item()
		if (not def.sounds) or (not def.groups)
		or (not nc.toolspeed(wield, def.groups)) then
			nc.node_sound(pos, "dig")
		else
			nc.node_sound(pos, "dig",
				{except = puncher})
		end

		if wield:get_wear() >= (65536 * 0.95) then
			wearfx(puncher, wield)
		end
	end)

nc.register_on_dignode(function(pos, node, digger)
		if not nc.player_visible(digger) then return end
		return nc.node_sound(pos, "dug",
			{node = node, except = digger})
	end)

nc.register_on_placenode(function(pos, node, placer)
		if not nc.player_visible(placer) then return end
		return nc.node_sound(pos, "place",
			{node = node, except = placer})
	end)

-- Work around 5.2 making dig/place sounds redundant,
-- but not backporting support to 5.0.
local function block_builtin_sounds(func)
	return function(...)
		local old_sound = core.sound_play
		function core.sound_play(spec, param, ephem, ...)
			if ephem and param.exclude_player then return end
			return old_sound(spec, param, ephem, ...)
		end
		local function helper(...)
			core.sound_play = old_sound
			return ...
		end
		return helper(func(...))
	end
end
core.item_place_node = block_builtin_sounds(core.item_place_node)
core.node_dig = block_builtin_sounds(core.node_dig)
