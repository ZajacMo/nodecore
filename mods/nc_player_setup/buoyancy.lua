-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local cached = {}
local function checkbuoy(player)
	-- Version must support "knockback".
	if not player.add_player_velocity then return end

	-- Player control must be idle, OR player must be
	-- "stuck", e.g. link-dead, which causes pos not to change.
	local linkdead
	if player:get_player_control_bits() ~= 0 then
		local pos = player:get_pos()
		local name = player:get_player_name()
		local opos = cached[name]
		if not (opos and vector.equals(pos, opos)) then
			cached[name] = pos
			return
		end
		linkdead = true
	end

	-- Player's body must be sufficiently submerged in water; we
	-- don't want the player to leap out of water.
	local pos = player:get_pos()
	local node = minetest.get_node({
			x = pos.x,
			y = pos.y + (player:get_properties().eye_height - 1) / 2 + 1,
			z = pos.z
		})
	if not nodecore.registered_liquids[node.name] then return end

	-- Player must have enough water around to use the "swim"
	-- animations; players standing in water don't buoy.
	if not nodecore.player_swimming(player) then return end

	-- Push buoyant players upward. If the player is linkdead then we
	-- need to set pos server-side, otherwise we can just advise the
	-- client to do the movement.
	if linkdead then
		pos.y = pos.y + 0.5
		return player:set_pos(pos)
	else
		return player:add_player_velocity({x = 0, y = 8, z = 0})
	end
end

local function timer()
	minetest.after(0.5, timer)
	for _, player in pairs(minetest.get_connected_players()) do
		checkbuoy(player)
	end
end
minetest.after(0, timer)
