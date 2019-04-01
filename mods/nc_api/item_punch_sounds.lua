-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

function nodecore.node_sound(pos, kind)
	if nodecore.stack_sounds(pos, kind) then return end
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	return minetest.sound_play(t.name, t)
end

local lasthit = {}

minetest.register_on_punchnode(function(pos, node, puncher, pointed)
		if not puncher then return end
		local pname = puncher:get_player_name()
		local now = minetest.get_us_time() / 1000000
		local last = lasthit[pname] or 0
		if now - last < 0.25 then return end

		local def = minetest.registered_items[node.name] or {}
		local wield = puncher:get_wielded_item()
		if (not def.groups) or (not nodecore.toolspeed(wield, def.groups))
		or not(def.sounds) then
			nodecore.node_sound(pos, "dig")
			lasthit[pname] = now
		end

		if wield:get_wear() >= (65536 * 0.95) then
			minetest.sound_play("nc_api_toolwear",
				{pos = pos, gain = 0.5})
		end
	end)
