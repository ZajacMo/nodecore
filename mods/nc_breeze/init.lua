-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random, math_sin, math_sqrt
    = math.random, math.sin, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local function windiness(y)
	if y < 0 then return 0 end
	if y > 512 then y = 512 end
	return math_sqrt(y) * (1 + 0.5 * math_sin(minetest.get_gametime() / 5))
end

nodecore.register_ambiance({
		label = "Tree Leaves Ambiance",
		nodenames = {"nc_tree:leaves"},
		neigbors = {"air"},
		interval = 1,
		chance = 100,
		sound_name = "nc_breeze_tree",
		check = function(pos)
			pos.y = pos.y + 1
			if pos.y <= 0 then return end
			return minetest.get_node(pos).name == "air"
			and minetest.get_node_light(pos, 0.5) == 15
			and { gain = windiness(pos.y) / 20 }
		end
	})

local function check(pos, done)
	local sp = {
		x = pos.x + math_random() * 64 - 32,
		y = pos.y + math_random() * 64 - 32,
		z = pos.z + math_random() * 64 - 32,
	}
	if sp.y <= 0 then return end
	local dist = vector.distance(sp, pos)
	if dist > 32 or dist < 4 then return end
	if minetest.get_node(sp).name ~= "air" then return end
	if minetest.get_node_light(sp, 0.5) < 15 then return end
	for p in pairs(done) do
		if vector.distance(sp, p) < 32 then return end
	end
	minetest.sound_play("nc_breeze_air", {
			pos = sp,
			gain = windiness(sp.y) / 100
		})
	done[pos] = true
end

local oldpos = {}
local function run()
	minetest.after(math_random(), run)
	local done = {}
	for _, pl in pairs(minetest.get_connected_players()) do
		local pname = pl:get_player_name()
		local pos = pl:get_pos()
		local op = oldpos[pname] or pos
		oldpos[pname] = pos
		pos = vector.add(pos, vector.multiply(vector.subtract(pos, op), 3))
		check(pos, done)
	end
end
run()
