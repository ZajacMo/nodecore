-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_exp, math_random
    = math.exp, math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

minetest.register_entity(modname .. ":fx", {
		initial_properties = {
			visual_size = {x = 0, y = 0},
			pointable = false,
			physical = true,
			is_visible = false,
			collide_with_objects = false,
			static_save = false
		},

		on_step = function(self, dtime)
			self.age = (self.age or 0) + dtime
			if self.age >= 5.5 then return self.object:remove() end
		end
	})

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
		if math_random(1, 2) ~= 1 then return end
		local np = {
			x = pos.x + math_random() * 64 - 32,
			y = pos.y + math_random() * 64 - 32,
			z = pos.z + math_random() * 64 - 32,
		}
		local ent = minetest.add_entity(sp, modname .. ":fx")
		ent:set_velocity(vector.multiply(vector.normalize(
					vector.subtract(np, sp)), 4 * math_random()))
		nodecore.sound_play("nc_envsound_air", {
				pos = sp,
				object = ent,
				gain = nodecore.windiness(sp.y) / 100,
				max_hear_distance = 64
			})
	elseif nodecore.get_node_light(sp) < 4 then
		nodecore.sound_play("nc_envsound_drip", {
				pos = sp,
				pitchvary = 0.4,
				gain = math_exp(math_random()) / 5,
				max_hear_distance = 64
			})
	end

	done[pos] = true
end

local oldpos = {}
nodecore.interval(math_random, function()
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

	end)
