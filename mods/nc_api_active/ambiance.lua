-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function ambiance_core(def, getpos)
	local max = def.queue_max or 20

	local seen = {}
	local queue = {}
	local total = 0

	nc.register_globalstep(function()
			if #queue < 1 then return end

			for i = 1, #queue do
				local opts = queue[i]
				opts.name = opts.name or def.sound_name
				opts.gain = opts.gain or def.sound_gain
				opts.pitch = opts.pitch or def.sound_pitch
				core.after(opts.delay, function()
						nc.sound_play(opts.name, opts)
					end)
			end

			seen = {}
			queue = {}
			total = 0
		end)

	def.action = function(...)
		local pos = getpos(...)
		local hash = core.hash_node_position(pos)
		if seen[hash] then return end
		seen[hash] = true
		local opts
		if def.check then
			opts = def.check(pos)
			if not opts then return end
			if opts == true then opts = {} end
		else
			opts = {}
		end
		opts.pos = pos
		opts.delay = (hash % 1000) / 1000
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
end

local function abm_pos(pos) return pos end
function nc.register_ambiance(def)
	ambiance_core(def, abm_pos)
	return core.register_abm(def)
end

local function aism_pos(_, data) return data.pos end
function nc.register_item_ambiance(def)
	ambiance_core(def, aism_pos)
	return nc.register_aism(def)
end
