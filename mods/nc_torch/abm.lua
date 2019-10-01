-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
		label = "Torch igniting",
		interval = 6,
		chance = 1,
		nodenames = {modname .. ":torch_lit"},
		neighbors = {"group:flammable"},
		action = function(pos)
			local check = {
				{x = 1, y = 0, z = 0},
				{x = -1, y = 0, z = 0},
				{x = 0, y = 0, z = 1},
				{x = 0, y = 0, z = -1},
				{x = 0, y = 1, z = 0}
			}
			for _, ofst in pairs(check) do
				local npos = vector.add(pos, ofst)
				local nbr = minetest.get_node(npos)
				if minetest.get_node_group(nbr.name, "flammable") > 0 and not nodecore.quenched(npos) then
					nodecore.fire_check_ignite(npos, nbr)
				end
			end
		end
	})

nodecore.register_limited_abm({
		label = "Torch expiration",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":torch_lit"},
		action = function(pos)
			if minetest.get_gametime() > minetest.get_meta(pos):get_int("expire") then
				minetest.set_node(pos, {name = "air"})
				minetest.add_item(pos, {name = "nc_fire:lump_ash"})
			end
		end
	})

nodecore.register_limited_abm({
		label = "Torch quenching",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":torch_lit"},
		action = function(pos)
			if nodecore.quenched(pos) then
				minetest.set_node(pos, {name = "nc_tree:stick"})
				minetest.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
			end
		end
	})
