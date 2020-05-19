-- LUALOCALS < ---------------------------------------------------------
local minetest, pairs
    = minetest, pairs
-- LUALOCALS > ---------------------------------------------------------

local liquids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v.liquidtype and v.liquidtype ~= "none" then
				liquids[k] = true
			end
		end
	end)

local function checkbuoy(player)
	if (not player.add_player_velocity)
	or (player:get_player_control_bits() ~= 0) then return end

	local pos = player:get_pos()
	local node = minetest.get_node({
			x = pos.x,
			y = pos.y + (player:get_properties().eye_height - 1) / 2 + 1,
			z = pos.z
		})
	if not liquids[node.name] then return end

	return player:add_player_velocity({x = 0, y = 8, z = 0})
end

local function timer()
	minetest.after(0.25, timer)
	for _, player in pairs(minetest.get_connected_players()) do
		checkbuoy(player)
	end
end
minetest.after(0, timer)
