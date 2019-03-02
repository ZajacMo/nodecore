-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local dirt = "nc_terrain:dirt"
local grass = "nc_terrain:dirt_with_grass"

nodecore.register_limited_abm({
		label = "Grass Spread",
		nodenames = {dirt, "nc_terrain:dirt_loose"},
		neighbors = {grass},
		interval = 6,
		chance = 50,
		action = function(pos, node)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if (minetest.get_node_light(above) or 0) < 13 then return end
			local nodedef = minetest.registered_nodes[node.name]
			if nodedef and nodedef.liquidtype ~= "none"
			and nodedef.drawtype ~= "airlike" then return end
			return minetest.set_node(pos, {name = grass})
		end
	})

nodecore.register_limited_abm({
		label = "Grass Decay",
		nodenames = {grass},
		interval = 8,
		chance = 50,
		action = function(pos, node)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local name = minetest.get_node(above).name
			local nodedef = minetest.registered_nodes[name]
			if name ~= "ignore" and nodedef and not ((nodedef.sunlight_propagates or
					nodedef.paramtype == "light") and
				nodedef.liquidtype == "none") then
				minetest.set_node(pos, {name = dirt})
			end
		end
	})
