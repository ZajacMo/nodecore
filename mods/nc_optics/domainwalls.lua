-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, vector
    = ipairs, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local active = {}

local function particles(item, player)
	local key = player:get_player_name() .. minetest.pos_to_string(item.pos, 1)
	.. minetest.pos_to_string(item.plane)
	local found = active[key]
	local now = minetest.get_us_time() / 1000000
	if found and found.exp > now then return end
	found = {
		exp = now + 2,
		id = minetest.add_particlespawner({
				amount = 10,
				time = 2,
				minpos = vector.add(item.pos,
					vector.multiply(item.plane, -0.1)),
				maxpos = vector.add(item.pos,
					vector.multiply(item.plane, 0.1)),
				minvel = vector.multiply(item.dir, -0.1),
				maxvel = vector.multiply(item.dir, 0.1),
				minacc = vector.multiply(item.plane, -0.25),
				maxacc = vector.multiply(item.plane, 0.25),
				minsize = 0.25,
				maxsize = 0.5,
				minexptime = 1,
				maxexptime = 2,
				texture = modname .. "_port_output.png",
				playername = player.name
			})
	}
	active[key] = found
end

local function processcbb(item)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local diff = pos and vector.subtract(pos, item.pos)
		if diff and vector.dot(diff, diff) < 64 then
			particles(item, player)
		end
	end
end

local get_node = minetest.get_node
nodecore.register_dnt({
		name = modname .. ":cbbs",
		time = 2,
		loop = true,
		ignore_stasis = true,
		nodenames = {"group:optic_source"},
		action = function(pos, node)
			local def = minetest.registered_nodes[node.name] or {}
			local src = def.optic_source
			if not src then return end
			src = src(pos, node)
			if not src then return end
			local cbbs = {}
			for _, dir in pairs(src) do
				nodecore.optic_scan(pos, dir, nil, get_node, cbbs)
			end
			for i = 1, #cbbs do processcbb(cbbs[i]) end
		end
	})

nodecore.register_limited_abm({
		label = modname .. ":cbbs",
		interval = 2,
		chance = 1,
		ignore_stasis = true,
		nodenames = {"group:optic_source"},
		action = function(pos)
			return nodecore.dnt_set(pos, modname .. ":cbbs", 2)
		end
	})
