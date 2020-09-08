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
	silktouch = false,
	after_dig_node = function(pos)
		nodecore.digparticles(pumdef, {
				time = 0.05,
				amount = 100,
				minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
				maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
				minvel = {x = -2, y = -2, z = -2},
				maxvel = {x = 2, y = 2, z = 2},
				minacc = {x = 0, y = -8, z = 0},
				maxacc = {x = 0, y = -8, z = 0},
				minexptime = 0.25,
				maxexptime = 0.5,
				collisiondetection = true,
				collision_removal = true,
				minsize = 1,
				maxsize = 6
			})
	end,
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.8),
}
minetest.register_node(pumname, pumdef)

do
	local dirs = nodecore.dirs()
	nodecore.register_limited_abm({
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

nodecore.register_limited_abm({
		label = "pumice melt",
		interval = 1,
		chance = 2,
		nodenames = {pumname},
		neighbors = {"group:lava"},
		action = function(pos)
			if math_random() < 0.95 and nodecore.quenched(pos) then return end
			nodecore.set_loud(pos, {name = "nc_terrain:lava_flowing", param2 = 7})
			pos.y = pos.y + 1
			return nodecore.fallcheck(pos)
		end
	})
