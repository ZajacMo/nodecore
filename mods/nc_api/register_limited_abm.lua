-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, unpack
    = math, minetest, nodecore, pairs, unpack
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local genlabels = 0

function nodecore.register_limited_abm(def)
	def = nodecore.underride(def, {
			limited_queue = {},
			limited_seen = {},
			limited_qty = 0,
			limited_max = 1000,
			limited_interval = 1,
			limited_jitter = 0.05,
			limited_action = def.action or function() end,
			catch_up = false
		})

	if not def.label then
		def.label = minetest.get_current_modname() .. ":" .. genlabels
		genlabels = genlabels + 1
	end

	def.action = function(pos, ...)
		local hash = minetest.hash_node_position(pos)
		local seen = def.limited_seen
		if seen[hash] then return end
		seen[hash] = true

		local q = def.limited_queue
		local max = def.limited_max
		local nqty = def.limited_qty + 1
		if #q < max then
			q[#q + 1] = {pos, ...}
		else
			local r = math_random(1, nqty)
			if r <= #q then q[r] = {pos, ...} end
		end
		def.limited_qty = nqty
	end

	local function pumpq()
		minetest.after(def.limited_interval
			- def.limited_jitter
			+ def.limited_jitter * math_random() * 2,
			pumpq)

		if def.limited_qty >= def.limited_max then
			minetest.log("limited abm \"" .. def.label .. "\" filled ("
				.. def.limited_qty .. "/" .. def.limited_max .. ")")
		end

		local act = def.limited_action
		for _, args in pairs(def.limited_queue) do
			act(unpack(args))
		end

		def.limited_queue = {}
		def.limited_seen = {}
		def.limited_qty = 0
	end
	pumpq()

	return minetest.register_abm(def)
end
