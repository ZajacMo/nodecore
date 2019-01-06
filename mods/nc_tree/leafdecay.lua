-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore
    = ipairs, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local seen = {}
local q = {}

minetest.register_abm({
		label = "Leaf Decay",
		interval = 1,
		chance = 10,
		nodenames = {modname .. ":leaves"},
		action = function(pos)
			local h = minetest.hash_node_position(pos)
			if seen[h] then return end
			if #q < 100 then
				q[#q + 1] = pos
			else
				q[math_random(1, #q)] = pos
			end
			seen[h] = true
		end
	})

nodecore.interval(1, function()
		for _, pos in ipairs(q) do
			if not nodecore.scan_flood(pos, 5, function(p)
					if nodecore.node_is(p, modname .. ":tree") then
						return true
					end
					if nodecore.node_is(p, modname .. ":leaves") then
						return
					end
					return false
				end) then
				nodecore.leaf_decay(pos)
			end
		end
		q = {}
		seen = {}
	end)
