-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

function nodecore.register_ambiance(def)
	local max = def.queue_max or 100
	local rate = 1 / (def.queue_rate or 20)

	local seen = {}
	local queue = {}
	local total = 0

	local batch
	local time = 0
	minetest.register_globalstep(function(dtime)
			time = time + dtime
			while time > rate do
				if not batch then
					if #queue < 1 then return end
					batch = queue
					queue = {}
					total = 0
					seen = {}
				end

				local opts = batch[#batch]
				batch[#batch] = nil
				if #batch < 1 then batch = nil end

				opts.name = opts.name or def.sound_name
				opts.gain = opts.gain or def.sound_gain
				nodecore.sound_play(opts.name, opts)

				time = time - rate
			end
		end)

	def.action = function(pos)
		local hash = minetest.hash_node_position(pos)
		if seen[hash] then return end
		seen[hash] = true
		local opts
		if def.check then
			opts = def.check(pos)
			if not opts then return end
		else
			opts = {}
		end
		opts.pos = pos
		if #queue < max then
			queue[#queue + 1] = opts
		else
			local r = math_random(1, total + 1)
			if r <= #queue then
				queue[r] = opts
			end
		end
		total = total + 1
	end

	return nodecore.register_limited_abm(def)
end
