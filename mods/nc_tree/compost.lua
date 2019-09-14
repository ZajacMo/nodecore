-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local airnames = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.air_equivalent then
				airnames[#airnames + 1] = k
			end
		end
	end)

local function addto(meta, key, max, func)
	local qty = (meta:get_float(key) or 0) + 1
	if qty >= max then return func() end
	return meta:set_float(key, qty)
end

nodecore.register_limited_abm({
		label = "Fallen Leaf Composting",
		interval = 10,
		chance = 2,
		nodenames = {modname .. ":leaves_loose"},
		neighbors = {"group:soil"},
		action = function(pos)
			local meta = minetest.get_meta(pos)
			local min = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}
			local max = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}
			local any
			for _, p in pairs(minetest.find_nodes_in_area(min, max, airnames)) do
				local nl = minetest.get_node_light(p, 0.5) or 0
				if nl >= 15 then
					return addto(meta, "air", 5, function()
							nodecore.node_sound(pos, "dig")
							return minetest.remove_node(pos)
						end)
				end
				any = true
			end
			if any then return end
			return addto(meta, "compost", 25, function()
					minetest.set_node(pos, {name = "nc_terrain:dirt_loose"})
					return nodecore.node_sound(pos, "place")
				end)
		end
	})
