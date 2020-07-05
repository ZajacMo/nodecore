-- LUALOCALS < ---------------------------------------------------------
local PcgRandom, minetest, nodecore
    = PcgRandom, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local genname = modname .. ":gen"

minetest.register_node(genname, {
		description = "Smoke Generator",
		inventory_image = "nc_api_craft_smoke.png",
		wield_image = "nc_api_craft_smoke.png",
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		groups = {snappy = 1}
	})

nodecore.register_dnt({
		name = genname,
		nodenames = {genname},
		time = 2,
		loop = true,
		ignore_stasis = true,
		action = function(pos)
			local pcg = PcgRandom(minetest.hash_node_position(pos))
			local rng = function() return pcg:next() / 2 ^ 32 + 0.5 end
			for _ = 1, 10 do
				local p = {
					x = pos.x + rng() - 0.5,
					y = pos.y + rng() * 2 - 0.5,
					z = pos.z + rng() - 0.5,
				}
				minetest.add_particle({
						pos = p,
						texture = "nc_api_craft_smoke.png",
						size = rng() * 2 + 1,
						expirationtime = 2.1
					})
			end
		end
	})

nodecore.register_abm({
		label = "smokegen",
		nodenames = {genname},
		interval = 1,
		chance = 1,
		ignore_stasis = true,
		action = function(pos) return nodecore.dnt_set(pos, genname) end
	})

nodecore.register_lbm({
		name = genname,
		nodenames = {genname},
		run_at_every_load = true,
		action = function(pos) return nodecore.dnt_reset(pos, genname, 0.01) end
	})
