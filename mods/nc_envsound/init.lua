-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_exp, math_random
    = math.exp, math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local function dsqr(a, b)
	local v = vector.subtract(a, b)
	return vector.dot(v, v)
end

local function check(pos, done, srcs)
	local sp = {
		x = pos.x + math_random() * 64 - 32,
		y = pos.y + math_random() * 64 - 32,
		z = pos.z + math_random() * 64 - 32,
	}

	if dsqr(sp, pos) > (32 * 32) then return end
	for p in pairs(done) do
		if dsqr(sp, p) < (32 * 32) then return end
	end
	for p in pairs(srcs) do
		if dsqr(sp, p) < (4 * 4) then return end
	end
	if minetest.get_node(sp).name ~= "air" then return end

	if nodecore.is_full_sun(sp) then
		if sp.y <= 0 then return end
		minetest.sound_play("nc_envsound_air", {
				pos = sp,
				gain = nodecore.windiness(sp.y) / 100
			})
	elseif nodecore.get_node_light(sp) < 4 then
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
	local srcs = {}
	for _, pl in pairs(minetest.get_connected_players()) do
		if nodecore.player_visible(pl) then
			local pname = pl:get_player_name()
			local pos = pl:get_pos()
			local op = oldpos[pname] or pos
			oldpos[pname] = pos
			pos = vector.add(pos, vector.multiply(vector.subtract(pos, op), 3))
			srcs[#srcs + 1] = pos
		end
	end
	local done = {}
	for _, pos in pairs(srcs) do
		check(pos, done, srcs)
	end

end
run()
