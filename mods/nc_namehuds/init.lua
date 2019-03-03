-- LUALOCALS < ---------------------------------------------------------
local math, minetest, pairs, tonumber
    = math, minetest, pairs, tonumber
local math_sqrt
    = math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

-- Maximum distance at which custom nametags are visible.
local distance = tonumber(minetest.setting_get(modname .. "_distance")) or 16

-- Precision (number of steps) for line-of-sight check for displaying nametags
local precision = tonumber(minetest.setting_get(modname .. "_precision")) or 50

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
		for k, v in pairs(huds) do
			local i = v[pn]
			if i then
				i.o:hud_remove(i.i)
				v[pn] = nil
			end
		end
	end)

------------------------------------------------------------------------
-- GLOBAL TICK HUD MANAGEMENT

-- Get custom text for a visible HUD.
local function gettext(p2, n2)
	-- First line: distance units, player HP.
	local t = "m"

	-- Check for a wielded item, and add its description
	-- to a line below if available.
	local w = p2:get_wielded_item()
	if w then
		local d = w:get_meta():get_string("description")
		if d then
			t = t .. "\n" .. d
		else
			w = w:get_name()
			local r = minetest.registered_items[w]
			t = t .. "\n" .. (r and r.description or w)
		end
	end

	return t
end

-- Determine if player 1 can see player 2's face, including
-- checks for distance, line-of-sight, and facing direction.
local function canseeface(p1, n1, p2, n2)
	-- Dead players neither see, nor are recognizable.
	if p1:get_hp() <= 0 or p2:get_hp() <= 0 then return end

	-- Players must be within max distance of one another,
	-- determined by light level.
	local o1 = p1:getpos()
	local o2 = p2:getpos()
	local ll = minetest.get_node_light({x = o2.x, y = o2.y + 1.65, z = o2.z})
	local ld = (ll / 15 * distance)
	local dx = o1.x - o2.x
	local dy = o1.y - o2.y
	local dz = o1.z - o2.z
	if (dx * dx + dy * dy + dz * dz) > (ld * ld) then return end

	-- Check for line of sight from approximage eye level
	-- of one player to the other.
	o1.y = o1.y + 1.65
	o2.y = o2.y + 1.65
	local l = minetest.line_of_sight(o1, o2, distance / precision)
	if not l then return end

	-- Players must be facing each other; cannot identify another
	-- player's face when their back is turned.  Note that
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
					if canseeface(p1, n1, p2, n2) then
						local p = p2:getpos()
						p.y = p.y + 1.25
						local t = gettext(p2, n2)

						-- Create a new HUD if not present.
						if not i then
							i = {o = p1, t = t, p = p}
							i.i = p1:hud_add({
									hud_elem_type = "waypoint",
									world_pos = p,
									name = n2,
									text = t,
									number = 0xffffff
								})
							h[n2] = i
						end

						-- Update HUD if outdated.
						if p.x ~= i.p.x or p.y ~= i.p.y or p.z ~= i.p.z then
							p1:hud_change(i.i, "world_pos", p)
							i.p = p
						end
						if i.t ~= t then
							p1:hud_change(i.i, "text", t)
							i.t = t
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
