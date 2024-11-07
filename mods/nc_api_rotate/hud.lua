-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, tostring, vector
    = core, math, nc, tostring, vector
local math_pi
    = math.pi
-- LUALOCALS > ---------------------------------------------------------

nc.amcoremod()

local modname = core.get_current_modname()

local vec_to_dir = nc.vector_to_dir
local huddots = nc.rotation_hud_dots

local transform_by_scrkey = {
	["0-1"] = "I",
	["10"] = "R270",
	["01"] = "R180",
	["-10"] = "R90",
}

nc.register_playerstep({
		label = "rotation scan",
		action = function(player, data)
			if player:get_player_control().sneak then
				huddots(player)
				return nc.hud_set(player, {
						label = modname,
						ttl = 0,
					})
			end

			local pt = data.raycast()

			local _, _, rot = nc.rotation_compute(player, pt)
			if not rot then
				huddots(player)
			end
			if not (rot and rot.param2) then
				return nc.hud_set(player, {
						label = modname,
						ttl = 0,
					})
			end
			huddots(player, rot.facectr, pt.intersection_normal, rot.boxscale)

			if not rot.rotdir then
				return nc.hud_set(player, {
						label = modname,
						hud_elem_type = "image_waypoint",
						text = "nc_api_rotate_hudarrow_long.png",
						scale = {x = 1, y = 1},
						world_pos = rot.facectr,
						precision = 0,
					})
			end

			local lookdir = player:get_look_dir()
			local camrt = core.yaw_to_dir(player:get_look_horizontal() - math_pi / 2)
			local camup = vector.cross(camrt, lookdir)
			local function screenspace(p)
				return vector.new(vector.dot(p, camrt), vector.dot(p, camup), 0)
			end
			local scrrot = screenspace(rot.rotdir)
			local scrnorm = screenspace(pt.intersection_normal)

			local txr = nc.tmod("nc_api_rotate_hudarrow_short.png")
			if vec_to_dir(vector.cross(scrrot, scrnorm)).z > 0 then
				txr = txr:transform("FX")
			end
			do
				local r = vec_to_dir(scrrot)
				txr = txr:transform(transform_by_scrkey[r.x .. r.y])
			end

			return nc.hud_set(player, {
					label = modname,
					hud_elem_type = "image_waypoint",
					text = tostring(txr),
					scale = {x = 1, y = 1},
					world_pos = vector.add(rot.facectr,
						vector.multiply(rot.rotdir, 0.4)),
					precision = 0,
				})
		end
	})
