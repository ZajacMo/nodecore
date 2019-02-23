-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local function envcheck(player)
	local stats = {}

	local pos = player:getpos()
	pos.y = pos.y + 1.6

	stats.light = minetest.get_node_light(pos)

	local target = vector.add(pos, {
			x = math_random() * 128 - 64,
			y = math_random() * 128 - 64,
			z = math_random() * 128 - 64
		})
	local _, hit = minetest.line_of_sight(pos, target)
	hit = hit or target

	stats.space = vector.distance(pos, hit)

	local node = minetest.get_node(hit)
	local def = minetest.registered_items[node.name]
	local groups = def.groups or {}

	stats.green = groups.green or 0
	stats.water = groups.water or 0 + stats.green / 5

	local pname = player:get_player_name()
	local agg = cache[pname]
	if not agg then
		agg = {}
		local raw = player:get_attribute("healthenv")
		if raw and raw ~= "" then
			agg = minetest.deserialize(raw)
		end
		cache[pname] = agg
	end
	for k, v in pairs(stats) do
		agg[k] = ((agg[k] or 0) * 99 + v) / 100
	end
	agg.dirty = (agg.dirty or 0) + 1
	if agg.dirty >= 20 then
		agg.dirty = nil
		player:set_attribute("healthenv",
			minetest.serialize(agg))
		nodecore.addphealth(player, 0.01 + (agg.green + 0.02)
			* (agg.water + 0.1)
			* (agg.space + 5)
			* (agg.light + 8) / 240)
	end

end

local t = 0
minetest.register_globalstep(function(dt)
		t = t + dt
		while t > 0.1 do
			t = t - 0.1
			for _, player in pairs(minetest.get_connected_players()) do
				if player:get_hp() > 0 then
					envcheck(player)
				end
			end
		end
	end)

minetest.register_on_dieplayer(function(player)		
		local inv = player:get_inventory()
		local pos = player:getpos()
		for i = 1, inv:get_size("main") do
			nodecore.item_eject(pos, inv:get_stack("main", i), 20)
		end
		inv:set_list("main", {})
		
		-- flush attributes
		player:set_attribute("healthenv", "")
		cache[player:get_player_name()] = nil
		player:set_attribute("dhp", "0")
	end)

minetest.register_on_respawnplayer(function(player)
		player:set_hp(1)
		player:set_attribute("dhp", "-0.4999")
	end)
