-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local pumname = modname .. ":pumice"

local pumdef
pumdef = {
	description = "Pumice",
	tiles = {"nc_igneous_pumice.png"},
	groups = {
		snappy = 2,
		cracky = 2,
		stack_as_node = 1
	},
	drop = "",
	destroy_on_dig = true,
	silktouch = false,
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.8),
}
minetest.register_node(pumname, pumdef)

do
	local dirs = nodecore.dirs()
	minetest.register_abm({
			label = "lava pumice",
			interval = 1,
			chance = 2,
			nodenames = {"nc_terrain:lava_flowing"},
			neighbors = {"group:coolant"},
			action = function(pos)
				if math_random() < 0.5 then
					local p = vector.add(pos, dirs[math_random(1, #dirs)])
					local n = minetest.get_node(p)
					if minetest.get_item_group(n.name, "water") > 0 then
						return nodecore.set_loud(p, {name = pumname})
					end
				end
				return nodecore.set_loud(pos, {name = pumname})
			end
		})
end

minetest.register_abm({
		label = "pumice melt",
		interval = 1,
		chance = 2,
		nodenames = {pumname},
		neighbors = {"group:lava"},
		arealoaded = 1,
		action = function(pos)
			if math_random() < 0.95 and nodecore.quenched(pos) then return end
			nodecore.set_loud(pos, {name = "nc_terrain:lava_flowing", param2 = 7})
			pos.y = pos.y + 1
			return nodecore.fallcheck(pos)
		end
	})
