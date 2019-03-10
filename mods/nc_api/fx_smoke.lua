-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local queue = {}
local qtotal = 0
local batch

minetest.register_globalstep(function()
		if not batch then
			if qtotal < 1 then return end
			batch = queue
			queue = {}
			qtotal = 0
		end
		if #batch < 1 then
			batch = nil
			return
		end

		local t = batch[#batch]
		batch[#batch] = nil

		minetest.add_particlespawner({
				texture = "nc_api_smoke.png",
				collisiondetection = true,
				amount = 4 * t.time,
				time = t.time,
				minpos = {x = t.pos.x - 0.4, y = t.pos.y - 0.4, z = t.pos.z - 0.4},
				maxpos = {x = t.pos.x + 0.4, y = t.pos.y + 0.4, z = t.pos.z + 0.4},
				minvel = {x = -0.1, y = 0.3, z = -0.1},
				maxvel = {x = 0.1, y = 0.7, z = 0.1},
				minexptime = 1,
				maxexptime = 5,
				minsize = 1,
				maxsize = 3	
			})
	end)

local qmax = 10

function nodecore.smoke(pos, time)
	if (not time) or (time <= 0) then return end
	if qtotal < qmax then
		queue[#queue + 1] = {pos = pos, time = time}
	else
		local r = math_random(1, qtotal + 1)
		if r <= qmax then queue[r] = {pos = pos, time = time} end
	end
	qtotal = qtotal + 1
end
