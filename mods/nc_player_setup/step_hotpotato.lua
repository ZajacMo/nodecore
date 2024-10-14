-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc
    = core, ipairs, nc
-- LUALOCALS > ---------------------------------------------------------

-- Any item in inventory can prevent hotpotato ejection if
-- it registers a method:
--
-- on_item_hotpotato(player, myslot, mystack, itemslot, itemstack, dtime, damage)
--
-- "my" slot / stack is the item providing the on_item_hotpotato
-- callback, "item" slot / stack is the hot item to be ejected.
--
-- When picking things up instead of carrying:
-- - dtime will be 0
-- - itemslot == myslot
--
-- return truthy to prevent ejection / damage.

nc.register_playerstep({
		label = "hot potatoes",
		action = function(player, data, dtime)
			if nc.stasis then return end
			local inv = player:get_inventory()
			local hurt = 0
			local throw = {}
			local overrides = {}
			for i = 1, inv:get_size("main") do
				local s = inv:get_stack("main", i)
				local n = not s:is_empty() and s:get_name()
				local def = n and core.registered_items[n]
				n = def and def.groups and def.groups.damage_pickup
				if (n or 0) == 0 then
					n = n and n.groups and n.groups.damage_touch
				end
				if n and n > 0 then
					throw[#throw + 1] = {i, s, n}
				end
				local o = def and def.on_item_hotpotato
				if o then
					overrides[#overrides + 1] = {o, i, s}
				end
			end
			if #throw > 0 then
				local pos = player:get_pos()
				pos.y = pos.y + 1.2
				local dir = player:get_look_dir()
				dir.x = dir.x * 5
				dir.y = dir.y * 5 + 3
				dir.z = dir.z * 5
				for _, v in ipairs(throw) do
					local skip
					for _, o in ipairs(overrides) do
						local cur = inv:get_stack("main", o[2])
						-- Make sure item hasn't been replaced during loop
						if cur:get_name() == o[3]:get_name() then
							skip = skip or o[1](player, o[2], cur, v[1], v[2], dtime, v[3])
							if skip then break end
						end
					end
					if not skip then
						hurt = hurt + v[3]
						inv:set_stack("main", v[1], "")
						local obj = core.add_item(pos, v[2])
						obj:set_velocity(dir)
						obj:get_luaentity().dropped_by = data.pname
					end
				end
			end
			if hurt > 0 then nc.addphealth(player, -hurt, "hotpotato") end
		end
	})
