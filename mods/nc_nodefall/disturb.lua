-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, vector
    = ipairs, math, minetest, nodecore, vector
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local falling = {groups = {falling_node = true}}
local radius = {x = 2, y = 2, z = 2}

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

	local found = minetest.find_nodes_in_area(
		vector.subtract(pos, radius),
		vector.add(pos, radius),
		"group:falling_node"
	)
	if #found < 1 then return end
	pos = nodecore.pickrand(found)

	local miny = pos.y - 64
	pos.y = pos.y - 1
	while pos.y >= miny and nodecore.match(pos, falling) do pos.y = pos.y - 1 end
	if pos.y < miny then return end
	pos.y = pos.y + 1
	local prev = minetest.get_node(pos).name
	nodecore.falling_repose_check(pos)
	if minetest.get_node(pos).name ~= prev then
		minetest.log(modname .. ": " .. name .. " disturbed "
			.. prev .. " at " .. minetest.pos_to_string(pos))
	end
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
minetest.register_globalstep(function(dtime)
		for _, v in ipairs(minetest.get_connected_players()) do
			local name = v:get_player_name()

			local pos = v:get_pos()
			local old = oldpos[name] or pos
			oldpos[name] = pos

			if v:get_player_control().sneak then return end

			local q = (qtys[name] or 0)
			+ vector.distance(pos, old) * 0.25
			+ dtime * 0.05
			queuechecks(math_floor(q), name, pos)
			qtys[name] = q - math_floor(q)
		end
	end)

minetest.register_on_dignode(function(pos, _, digger)
		local name = "(unknown)"
		if digger and digger.get_player_name then name = digger:get_player_name() end
		queuechecks(4, name, pos)
	end)
