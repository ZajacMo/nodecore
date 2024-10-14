-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, string, vector
    = core, math, nc, pairs, string, vector
local math_exp, math_random, string_format
    = math.exp, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

nc.amcoremod()

local modname = core.get_current_modname()

local entname = modname .. ":fx"

core.register_entity(entname, {
		initial_properties = {
			visual_size = {x = 0, y = 0},
			pointable = false,
			physical = true,
			is_visible = false,
			collide_with_objects = false,
			static_save = false
		}
	})

nc.interval(10, function()
		local cutoff = (nc.gametime or 0) - 60
		for _, ent in pairs(core.luaentities) do
			if ent.name == entname and ent.born <= cutoff then
				ent.object:remove()
			end
		end
	end)

local function dsqr(a, b)
	local v = vector.subtract(a, b)
	return vector.dot(v, v)
end

local poolent
do
	local reused = 0
	local created = 0
	function poolent(pos)
		local cutoff = nc.gametime - 5.5
		local bestent
		local bestd
		for _, ent in pairs(core.luaentities) do
			if ent.name == entname and ent.born <= cutoff then
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
			bestent.born = nc.gametime
			return bestent.object
		end
		created = created + 1
		local obj = core.add_entity(pos, entname)
		if not obj then return end
		obj:get_luaentity().born = nc.gametime
	end
	nc.interval(300, function()
			nc.log("info", string_format("%s reused %d created %d",
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
	if core.get_node(sp).name ~= "air" then return end

	if nc.is_full_sun(sp) then
		if sp.y <= 0 then return end
		if math_random(1, 2) ~= 1 then return end
		local np = {
			x = pos.x + math_random() * 64 - 32,
			y = pos.y + math_random() * 64 - 32,
			z = pos.z + math_random() * 64 - 32,
		}
		local ent = poolent(sp)
		if ent then
			ent:set_velocity(vector.multiply(vector.normalize(
						vector.subtract(np, sp)), 4 * math_random()))
			nc.sound_play("nc_envsound_air", {
					pos = sp,
					object = ent,
					gain = nc.windiness(sp.y) / 100,
					max_hear_distance = 64
				})
		end
	elseif nc.get_node_light(sp) < 4 then
		nc.sound_play("nc_envsound_drip", {
				pos = sp,
				pitchvary = 0.4,
				gain = math_exp(math_random()) / 5,
				max_hear_distance = 64
			})
	end

	done[pos] = true
end

local oldpos = {}
nc.interval(math_random, function()
		local srcs = {}
		for _, pl in pairs(core.get_connected_players()) do
			if nc.player_visible(pl) then
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
