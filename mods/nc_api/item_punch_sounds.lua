-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

function nodecore.node_sound(pos, kind, except)
	if nodecore.stack_sounds(pos, kind) then return end
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	if not except then return minetest.sound_play(t.name, t) end
	for _, p in ipairs(minetest.get_connected_players()) do
		if p ~= except and vector.distance(p:get_pos(), pos) <= 32 then
			t.to_player = p:get_player_name()
			minetest.sound_play(t.name, t)
		end
	end
end

local lasthit = {}

minetest.register_on_punchnode(function(pos, node, puncher, pointed)
		if not puncher then return end
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
			nodecore.node_sound(pos, "dig", puncher)
		end

		if wield:get_wear() >= (65536 * 0.95) then
			minetest.sound_play("nc_api_toolwear",
				{pos = pos, gain = 0.5})
		end
	end)

minetest.register_on_dignode(function(pos, node, digger)
		return nodecore.node_sound(pos, "dug", digger)
	end)

minetest.register_on_placenode(function(pos, node, placer)
		return nodecore.node_sound(pos, "place", placer)
	end)
