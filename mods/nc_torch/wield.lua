-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, vector
    = minetest, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local wl_timer = 0
local ex_timer = 0
minetest.register_globalstep(function(dt)
		wl_timer, ex_timer = wl_timer + dt, ex_timer + dt
		if wl_timer > 0.2 then
			for _, player in pairs(minetest.get_connected_players()) do
				local ppos = player:get_pos()
				if ex_timer > 1 then
					local head = minetest.get_node(vector.add(ppos, {x = 0, y = 1, z = 0})).name
					local inv = player:get_inventory()
					if inv:contains_item("main", modname .. ":torch_lit") then
						local list = inv:get_list("main")
						for i, stack in pairs(list) do
							if stack:get_name() == modname .. ":torch_lit" then
								if minetest.get_node_group(head, "water") > 0 then
									minetest.sound_play("nc_fire_snuff", {object = player, gain = 0.5})
									inv:set_stack("main", i, "nc_tree:stick")
								elseif minetest.get_gametime() > stack:get_meta():get_int("expire") then
									inv:set_stack("main", i, "nc_fire:lump_ash")
								end
							end
						end
					end
					ex_timer = 0
				end
				if player:get_wielded_item():get_name() == modname .. ":torch_lit" then
					local pos = vector.add(ppos, {x = 0, y = 1, z = 0})
					local cur = minetest.get_node(pos).name
					if cur == "air" or cur == modname .. ":wield_light" then
						minetest.set_node(pos, {name = modname .. ":wield_light"})
						minetest.get_node_timer(pos):start(0.3)
					end
				end
			end
			wl_timer = 0
		end
	end)
