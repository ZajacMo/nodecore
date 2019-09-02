-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_exp, math_random
    = math.exp, math.random
-- LUALOCALS > ---------------------------------------------------------

local function check(pos, done)
	local sp = {
		x = pos.x + math_random() * 64 - 32,
		y = pos.y + math_random() * 64 - 32,
		z = pos.z + math_random() * 64 - 32,
	}

	local dist = vector.distance(sp, pos)
	if dist > 32 or dist < 4 then return end
	for p in pairs(done) do
		if vector.distance(sp, p) < 32 then return end
	end
	if minetest.get_node(sp).name ~= "air" then return end

	local light = minetest.get_node_light(sp, 0.5)
	if light == 15 then
		if sp.y <= 0 then return end
		minetest.sound_play("nc_envsound_air", {
				pos = sp,
				gain = nodecore.windiness(sp.y) / 100
			})
	elseif light < 4 then
		minetest.sound_play("nc_envsound_drip", {
				pos = sp,
				pitchvary = 0.4,
				gain = math_exp(math_random()) / 5
			})
	end

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
