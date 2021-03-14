-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, vector
    = math, minetest, nodecore, pairs, string, vector
local math_pow, math_random, string_format
    = math.pow, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local lavaname = "nc_terrain:lava_source"
local stonename = "nc_terrain:stone"

local function process(pos)
	local node = minetest.get_node(pos)
	if node.name ~= stonename then return end

	local lavas = 0
	for _, dir in pairs(nodecore.dirs()) do
		if minetest.get_node(vector.add(pos, dir)) == lavaname then
			lavas = lavas + 1
		end
	end
	if (lavas < 4) or (math_random() > math_pow(1.5, lavas - 4) / 3) then return end

	nodecore.log("action", string_format("%s melted to %s at %s (%d sources)",
			stonename, lavaname, minetest.pos_to_string(pos), lavas))
	nodecore.witness(pos, "stone melted")
	return nodecore.set_loud(pos, {name = lavaname})
end

local queue = {}

nodecore.register_globalstep("stone hardening", function()
		for _, p in pairs(queue) do process(p) end
		queue = {}
	end)

nodecore.register_limited_abm({
		label = "stone hardening",
		nodenames = {lavaname},
		neighbors = {stonename},
		interval = 10,
		chance = 125,
		action = function(pos)
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:stone")) do
				queue[minetest.hash_node_position(p)] = p
			end
		end
	})
