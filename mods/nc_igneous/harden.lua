-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local harden_to = {}
local harden_idx = {}
local soften_to = {}
minetest.after(0, function()
		for _, v in pairs(minetest.registered_nodes) do
			if v.strata then
				for i, n in pairs(v.strata) do
					harden_to[n] = v.strata[i + 1]
					soften_to[n] = v.strata[i - 1]
					harden_idx[n] = i
				end
			end
		end
	end)

local queue = {}

local function process(pos)
	local water = #nodecore.find_nodes_around(pos, "group:water")
	local lux = #nodecore.find_nodes_around(pos, "group:lux_fluid")
	if water == lux then return end

	local node = minetest.get_node(pos)
	node.name = (water > lux and harden_to or soften_to)[node.name]
	if not node.name then return end

	local lava = #nodecore.find_nodes_around(pos, "group:lava")
	if lava < 1 then return end

	local fluid = water > lux and (water - lux) or (lux - water)
	local chance = harden_idx[node.name] - (fluid > lava and fluid or lava) / 8
	if (chance > 0) and (math_random() > (1/3) ^ chance) then return end
	nodecore.log("action", (water > lux and "hardened" or "softened")
		.. " to " .. node.name .. " at " .. minetest.pos_to_string(pos))
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
			if not minetest.find_node_near(pos, 2,
				{"group:water", "group:lux_fluid"}) then return end
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:stone")) do
				queue[minetest.hash_node_position(p)] = p
			end
		end
	})
