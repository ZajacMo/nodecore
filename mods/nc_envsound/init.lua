-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, vector
    = math, minetest, nodecore, pairs, string, vector
local math_exp, math_random, string_format
    = math.exp, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local entname = modname .. ":fx"

minetest.register_entity(entname, {
		initial_properties = {
			visual_size = {x = 0, y = 0},
			pointable = false,
			physical = true,
			is_visible = false,
			collide_with_objects = false,
			static_save = false
		},
		age = 0,
		on_step = function(self, dtime)
			self.age = self.age + dtime
			if self.age > 60 then return self.object:remove() end
		end
	})

local function dsqr(a, b)
	local v = vector.subtract(a, b)
	return vector.dot(v, v)
end

local poolent
do
	local reused = 0
	local created = 0
	function poolent(pos)
		local bestent
		local bestd
		for _, ent in pairs(minetest.luaentities) do
			if ent.name == entname and ent.age >= 5.5 then
				local op = ent.object:get_pos()
				if op then
					local d = dsqr(pos, op)
					if (not bestd) or d < bestd then
						bestd = d
						bestent = ent
					end
				end
			end
		end
		if bestent then
			reused = reused + 1
			bestent.object:set_pos(pos)
			bestent.age = 0
			return bestent.object
		end
		created = created + 1
		return minetest.add_entity(pos, entname)
	end
	nodecore.interval(300, function()
			nodecore.log("info", string_format("%s reused %d created %d",
					modname, reused, created))
			reused = 0
			created = 0
		end)
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
		local ent = poolent(sp)
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
