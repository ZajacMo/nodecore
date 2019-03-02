-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, print, tostring, vector
    = ipairs, math, minetest, nodecore, print, tostring, vector
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
	local clr, pos = minetest.line_of_sight(start, target)
	if clr then return end

	local found = minetest.find_nodes_in_area(
		vector.subtract(pos, radius),
		vector.subtract(pos, radius),
		"group:falling_node")
	if #found < 1 then return end
	pos = nodecore.pickrand(found)

	local miny = pos.y - 64
	repeat pos.y = pos.y - 1 until pos.y < miny or not nodecore.match(pos, falling)
	if pos.y < miny then return end
	pos.y = pos.y + 1
	local prev = minetest.get_node(pos).name
	nodecore.falling_repose_check(pos)
	if minetest.get_node(pos).name ~= prev then
		print(modname .. ": " .. name .. " disturbed "
			.. prev .. " at " .. tostring(pos))
	end
end

local function queuechecks(qty, name, pos)
	if qty < 1 then return end
	minetest.after(0, function()
			for i = 1, qty do
				fallcheck(name, pos)
			end
		end)
end

local oldpos = {}
local qtys = {}
minetest.register_globalstep(function(dtime)
		for i, v in ipairs(minetest.get_connected_players()) do
			local name = v:get_player_name()

			local pos = v:getpos()
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

minetest.register_on_dignode(function(pos, oldnode, digger)
		local name = "(unknown)"
		if digger and digger.get_player_name then name = digger:get_player_name() end
		queuechecks(4, name, pos)
	end)
