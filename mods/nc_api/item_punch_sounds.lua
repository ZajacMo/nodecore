-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local lasthit = {}

local function wearfx(puncher, wield)
	nodecore.sound_play("nc_api_toolwear",
		{object = puncher, gain = 0.5})
	local ppos = puncher:get_pos()
	if not ppos then return end
	ppos.y = ppos.y + puncher:get_properties().eye_height - 0.1
	local look = puncher:get_look_dir()
	for _ = 1, 3 do
		nodecore.digparticles(wield:get_definition(), {
				time = 0.05,
				amount = 1,
				minpos = ppos,
				maxpos = ppos,
				minvel = vector.add(look, {x = -1, y = -1, z = -1}),
				maxvel = vector.add(look, {x = 1, y = 1, z = 1}),
				minacc = {x = 0, y = -8, z = 0},
				maxacc = {x = 0, y = -8, z = 0},
				minexptime = 0.25,
				maxexptime = 1
			})
	end
end

nodecore.register_on_punchnode("node punch sounds", function(pos, node, puncher)
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
			wearfx(puncher, wield)
		end
	end)

nodecore.register_on_dignode("other player dig sounds", function(pos, node, digger)
		if not nodecore.player_visible(digger) then return end
		return nodecore.node_sound(pos, "dug",
			{node = node, except = digger})
	end)

nodecore.register_on_placenode("other player place sounds", function(pos, node, placer)
		if not nodecore.player_visible(placer) then return end
		return nodecore.node_sound(pos, "place",
			{node = node, except = placer})
	end)

-- Work around 5.2 making dig/place sounds redundant,
-- but not backporting support to 5.0.
local function block_builtin_sounds(func)
	return function(...)
		local old_sound = minetest.sound_play
		function minetest.sound_play(spec, param, ephem, ...)
			if ephem and param.exclude_player then return end
			return old_sound(spec, param, ephem, ...)
		end
		local function helper(...)
			minetest.sound_play = old_sound
			return ...
		end
		return helper(func(...))
	end
end
minetest.item_place_node = block_builtin_sounds(minetest.item_place_node)
minetest.node_dig = block_builtin_sounds(minetest.node_dig)
