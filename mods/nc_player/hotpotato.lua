local function hotpotatoes(player)
	local inv = player:get_inventory()
	local hurt = 0
	local throw = {}
	for i = 1, inv:get_size("main") do
		local s = inv:get_stack("main", i)
		local n = not s:is_empty() and s:get_name()
		n = n and minetest.registered_items[n]
		n = n and n.damage_per_second
		if n and n > 0 then
			hurt = hurt + n
			inv:set_stack("main", i, "")
			throw[#throw + 1] = s
		end
	end
	if #throw > 0 then
		local pname = player:get_player_name()
		local pos = player:get_pos()
		pos.y = pos.y + 1.2
		local dir = player:get_look_dir()
		dir.x = dir.x * 5
		dir.y = dir.y * 5 + 3
		dir.z = dir.z * 5
		for k, v in pairs(throw) do
			local obj = minetest.add_item(pos, v)
			obj:set_velocity(dir)
			obj:get_luaentity().dropped_by = pname
		end
	end
	if hurt > 0 then player:set_hp(player:get_hp() - hurt) end
end

minetest.register_globalstep(function()
		for k, v in pairs(minetest.get_connected_players()) do
			hotpotatoes(v)
		end
	end)