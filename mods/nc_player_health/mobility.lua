-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_pow, math_random, math_sqrt
    = math.pow, math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local function setspeed(player, speed)
	if speed > 1 then speed = 1 end
	if speed < 0 then speed = 0 end
	speed = speed * 1.25
	local phys = player:get_physics_override()
	if phys.speed == speed then return end
	phys.speed = speed
	return player:set_physics_override(phys)
end

local function mobility(player)
	local health = nodecore.getphealth(player) / 20
	if health >= 1 then return setspeed(player, 1) end

	local inv = player:get_inventory()
	local encumb = 0
	local invsize = inv:get_size("main")
	for i = 1, invsize do
		if not inv:get_stack("main", i):is_empty() then
			encumb = encumb + 1
		end
	end
	encumb = encumb / invsize
	if encumb <= health then return setspeed(player, 1) end
	
	return setspeed(player, math_pow(1 - math_sqrt(encumb - health) * 0.8,
			math_random() * 2 + 1))
end

local function timer()
	minetest.after(0.5, timer)
	for _, p in pairs(minetest.get_connected_players()) do
		if p:get_hp() > 0 then mobility(p) end
	end
end
timer()
