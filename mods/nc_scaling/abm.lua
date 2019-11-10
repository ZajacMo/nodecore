-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function closenough(pos, player)
	local pp = player:get_pos()
	pp.y = pp.y + 1
	return vector.distance(pos, pp) <= 5
end

nodecore.register_limited_abm({
		label = "Scaling Decay",
		interval = 1,
		chance = 1,
		limited_max = 100,
		nodenames = {"group:" .. modname},
		action = function(pos)
			local data = minetest.get_meta(pos):get_string("data")
			if (not data) or (data == "") then
				return minetest.remove_node(pos)
			end
			data = minetest.deserialize(data)
			if minetest.get_node(data.pos).name ~= data.node then
				return minetest.remove_node(pos)
			end
			for _, p in pairs(minetest.get_connected_players()) do
				if closenough(pos, p) then return end
			end
			return minetest.remove_node(pos)
		end
	})

nodecore.register_limited_abm({
		label = "Scaling FX",
		interval = 1,
		chance = 1,
		limited_max = 100,
		nodenames = {"group:" .. modname .. "_fx"},
		action = function(pos)
			return nodecore.scaling_particles(pos)
		end
	})
