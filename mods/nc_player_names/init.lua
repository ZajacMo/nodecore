-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, tonumber
    = math, minetest, nodecore, pairs, tonumber
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

-- Maximum distance at which custom nametags are visible.
local distance = tonumber(minetest.settings:get(modname .. "_distance")) or 16

-- Keep track of active player HUDs.
local huds = {}

------------------------------------------------------------------------
-- PLAYER JOIN/LEAVE

-- On player joining, disable the built-in nametag by setting its
-- text to whitespace and color to transparent.
minetest.register_on_joinplayer(function(player)
		player:set_nametag_attributes({
				text = " ",
				color = {a = 0, r = 0, g = 0, b = 0}
			})
	end)

-- On player leaving, clean up any associated HUDs.
minetest.register_on_leaveplayer(function(player)
		-- Garbage-collect player's own HUDs.
		local pn = player:get_player_name()
		huds[pn] = nil

		-- Remove HUDs for this player's name
		-- from other players
		for _, v in pairs(huds) do
			local i = v[pn]
			if i then
				i.o:hud_remove(i.i)
				v[pn] = nil
			end
		end
	end)

------------------------------------------------------------------------
-- GLOBAL TICK HUD MANAGEMENT

local function fluidmedium(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if not def then return node.name end
	if def.sunlight_propagates then return "CLEAR" end
	return def.liquid_alternative_source or node.name
end

-- Determine if player 1 can see player 2's face, including
-- checks for distance, line-of-sight, and facing direction.
local function canseeface(p1, p2)
	if p1:get_hp() <= 0 or p2:get_hp() <= 0 then return end
	if p1:get_attach() or p2:get_attach() then return end
	if not nodecore.player_visible(p2) then return end

	-- Players must be within max distance of one another,
	-- determined by light level, but not too close.
	local o1 = p1:get_pos()
	local o2 = p2:get_pos()
	local e1 = p1:get_properties().eye_height or 1.625
	local e2 = p2:get_properties().eye_height or 1.625
	local dx = o1.x - o2.x
	local dy = o1.y - o2.y
	local dz = o1.z - o2.z
	local dsqr = (dx * dx + dy * dy + dz * dz)
	if dsqr < 1 then return end
	local ll = minetest.get_node_light({x = o2.x, y = o2.y + e2, z = o2.z})
	if not ll then return end
	local ld = (ll / 15 * distance)
	if dsqr > (ld * ld) then return end

	-- Make sure players' eyes are inside the same fluid.
	o1.y = o1.y + e1
	o2.y = o2.y + e2
	local f1 = fluidmedium(o1)
	local f2 = fluidmedium(o2)
	if f1 ~= f2 then return end

	-- Check for line of sight from approximate eye level
	-- of one player to the other.
	for pt in minetest.raycast(o1, o2, true, true) do
		if pt.type == "node" then
			if fluidmedium(pt.under) ~= f1 then return end
		elseif pt.type == "object" then
			if pt.ref ~= p1 and pt.ref ~= p2 then return end
		else
			return
		end
	end

	-- Players must be facing each other; cannot identify another
	-- player's face when their back is turned. Note that
	-- minetest models don't show pitch, so ignore the y component.

	-- Compute normalized 2d vector from one player to another.
	local d = dx * dx + dz * dz
	if d == 0 then return end
	d = math_sqrt(d)
	dx = dx / d
	dz = dz / d

	-- Compute normalized 2d facing direction vector for target player.
	local l2 = p2:get_look_dir()
	d = l2.x * l2.x + l2.z * l2.z
	if d == 0 then return end
	d = math_sqrt(d)
	l2.x = l2.x / d
	l2.z = l2.z / d

	-- Compare directions via dot product.
	if (dx * l2.x + dz * l2.z) <= 0.5 then return end

	return true
end

-- On each global step, check all player visibility, and create/remove/update
-- each player's HUDs accordingly.
minetest.register_globalstep(function()
		local conn = minetest.get_connected_players()
		for _, p1 in pairs(conn) do
			local n1 = p1:get_player_name()
			local h = huds[n1]
			if not h then
				h = {}
				huds[n1] = h
			end
			for _, p2 in pairs(conn) do
				if p2 ~= p1 then
					local n2 = p2:get_player_name()
					local i = h[n2]
					if canseeface(p1, p2) then
						local p = p2:get_pos()
						p.y = p.y + 1.25

						-- Create a new HUD if not present.
						if not i then
							i = {o = p1, p = p}
							i.i = p1:hud_add({
									hud_elem_type = "waypoint",
									world_pos = p,
									name = n2,
									text = "",
									number = 0xffffff
								})
							h[n2] = i
						end

						-- Update HUD if outdated.
						if p.x ~= i.p.x or p.y ~= i.p.y or p.z ~= i.p.z then
							p1:hud_change(i.i, "world_pos", p)
							i.p = p
						end
					elseif i then
						-- Remove HUD if visibility lost.
						p1:hud_remove(i.i)
						h[n2] = nil
					end
				end
			end
		end
	end)
