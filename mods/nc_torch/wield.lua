-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs, vector
    = minetest, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function islit(stack)
	return stack:get_name() == modname .. ":torch_lit"
end

local function snuffinv(player, inv, i)
	minetest.sound_play("nc_fire_snuff", {object = player, gain = 0.5})
	inv:set_stack("main", i, "nc_fire:lump_ash")
end

local wltimers = {}
minetest.register_globalstep(function()
		local now = minetest.get_gametime()
		for _, player in pairs(minetest.get_connected_players()) do
			local inv = player:get_inventory()
			local ppos = player:get_pos()

			-- Snuff all torches if doused in water.
			local hpos = vector.add(ppos, {x = 0, y = 1, z = 0})
			local head = minetest.get_node(hpos).name
			if minetest.get_node_group(head, "water") > 0 then
				for i = 1, inv:get_size("main") do
					local stack = inv:get_stack("main", i)
					if islit(stack) then snuffinv(player, inv, i) end
				end
			else
				-- Snuff torches that have expired.
				for i = 1, inv:get_size("main") do
					local stack = inv:get_stack("main", i)
					if islit(stack) and now > stack:get_meta()
					:get_float("expire") then snuffinv(player, inv, i) end
				end

				-- Wield light
				if islit(player:get_wielded_item()) then
					local name = player:get_player_name()
					local t = wltimers[name] or 0
					if t <= now then
						wltimers[name] = now + 0.2
						local cur = minetest.get_node(hpos).name
						if cur == "air" or cur == modname .. ":wield_light" then
							minetest.set_node(hpos, {name = modname .. ":wield_light"})
							minetest.get_node_timer(hpos):start(0.3)
						end
					end
				end
			end
		end
	end)
