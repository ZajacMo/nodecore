-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_exp, math_random, math_sqrt
    = math.exp, math.random, math.sqrt
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
	if agg.dirty >= 5 then
		agg.dirty = nil
		player:set_attribute("healthenv",
			minetest.serialize(agg))
		for k, v in pairs(agg) do
			agg[k] = 1 - math_exp(-v)
		end
		local heal = 0.1
		+ (agg.green * agg.green) * 4
		+ (agg.water * agg.water) * 2
		+ (agg.space * agg.space)
		+ (agg.light * agg.light)
		heal = math_sqrt(heal)
		nodecore.addphealth(player, heal)
	end

end

minetest.register_on_dieplayer(function(player)		
		player:set_attribute("healthenv", "")
		cache[player:get_player_name()] = nil
	end)

local function timer()
	minetest.after(0.5, timer)
	for _, p in pairs(minetest.get_connected_players()) do
		if p:get_hp() > 0 then envcheck(p) end
	end
end
timer()
