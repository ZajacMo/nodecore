-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
	label = "Torch igniting",
	interval = 6,
	chance = 1,
	nodenames = {modname .. ":torch_lit"},
	neighbors = {"group:flammable"},
	action = function(pos, node)
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
			if minetest.get_node_group(nbr.name, "flammable") > 0 then
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
	action = function(pos, node)
		if minetest.get_gametime() > minetest.get_meta(pos):get_int("expire") then
			minetest.set_node(pos, {name = "air"})
			minetest.add_item(pos, {name = "nc_fire:lump_ash"})
		end
	end
})

local wl_timer = 0
local ex_timer = 0
minetest.register_globalstep(function(dt)
	wl_timer, ex_timer = wl_timer + dt, ex_timer + dt
	if wl_timer > 0.2 then
		for _, player in pairs(minetest.get_connected_players()) do
			if ex_timer > 1 then
				local inv = player:get_inventory()
				if inv:contains_item("main", modname .. ":torch_lit") then
					local list = inv:get_list("main")
					for i, stack in pairs(list) do
						if stack:get_name() == modname .. ":torch_lit" then
							if minetest.get_gametime() > stack:get_meta():get_int("expire") then
								inv:set_stack("main", i, "nc_fire:lump_ash")
							end
						end
					end
				end
				ex_timer = 0
			end
			if player:get_wielded_item():get_name() == modname .. ":torch_lit" then
				local pos = vector.add(player:get_pos(), {x = 0, y = 1, z = 0})
				local cur = minetest.get_node(pos).name
				if cur == "air" or cur == modname .. ":wield_light" then
					minetest.set_node(pos, {name = modname .. ":wield_light"})
					minetest.get_node_timer(pos):start(0.3)
				end
			end
		end
		timer = 0
	end
end)
