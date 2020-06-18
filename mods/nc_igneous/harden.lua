-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local harden_to = {}
local harden_idx = {}
minetest.after(0, function()
		for _, v in pairs(minetest.registered_nodes) do
			if v.strata then
				for i, n in pairs(v.strata) do
					harden_to[n] = v.strata[i + 1]
					harden_idx[n] = i
				end
			end
		end
	end)

local queue = {}

local function process(pos)
	local node = minetest.get_node(pos)
	node.name = harden_to[node.name]
	if not node.name then return end

	local water = #nodecore.find_nodes_around(pos, "group:water")
	local lava = #nodecore.find_nodes_around(pos, "group:lava")
	if water < 1 or lava < 1 then return end

	local chance = harden_idx[node.name] - (water > lava and water or lava) / 8
	if (chance > 0) and (math_random() > 0.5 ^ chance) then return end

	return nodecore.set_loud(pos, node)
end

nodecore.register_globalstep("stone hardening", function()
		for _, p in pairs(queue) do process(p) end
		queue = {}
	end)

nodecore.register_limited_abm({
		label = "stone hardening",
		nodenames = {"group:lava"},
		neighbors = {"group:stone"},
		interval = 10,
		chance = 50,
		action = function(pos)
			if not minetest.find_node_near(pos, 2, "group:water") then return end
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:stone")) do
				queue[minetest.hash_node_position(p)] = p
			end
		end
	})
