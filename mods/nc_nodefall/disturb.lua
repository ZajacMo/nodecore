-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local falling = {groups = {falling_node = true}}

local function fallcheck(name, start)
	if not nodecore.interact(name) then return end

	local target = vector.add(start, {
			x = math_random() * 128 - 64,
			y = math_random() * 128 - 64,
			z = math_random() * 128 - 64
		})
	local pointed = minetest.raycast(start, target, false)()
	if not pointed or not pointed.under then return end
	local pos = pointed.under

	local found = nodecore.find_nodes_around(pos, "group:falling_node", 2)
	if #found < 1 then return end
	pos = nodecore.pickrand(found)

	local miny = pos.y - 64
	pos.y = pos.y - 1
	while pos.y >= miny and nodecore.match(pos, falling) do pos.y = pos.y - 1 end
	if pos.y < miny then return end
	pos.y = pos.y + 1
	return minetest.check_for_falling(pos)
end

local function queuechecks(qty, name, pos)
	if qty < 1 then return end
	minetest.after(0, function()
			for _ = 1, qty do
				fallcheck(name, pos)
			end
		end)
end

local oldpos = {}
local qtys = {}
local function playercheck(dtime, player)
	if not nodecore.interact(player) then return end

	local name = player:get_player_name()

	local pos = player:get_pos()
	local old = oldpos[name] or pos
	oldpos[name] = pos

	if player:get_player_control().sneak or
	not nodecore.player_visible(player) then return end

	local dist = vector.distance(pos, old)
	if dist > 20 then dist = 20 end
	local q = (qtys[name] or 0) + dist * 0.25 + dtime * 0.05
	queuechecks(math_floor(q), name, pos)
	qtys[name] = q - math_floor(q)
end
nodecore.register_playerstep({
		label = "fallingnode disturbance",
		action = function(player, _, dtime)
			if not nodecore.stasis then return playercheck(dtime, player) end
		end
	})

nodecore.register_on_dignode("nodefall disturb on dig", function(pos, _, digger)
		local name = "(unknown)"
		if digger and digger.get_player_name then name = digger:get_player_name() end
		queuechecks(4, name, pos)
	end)
