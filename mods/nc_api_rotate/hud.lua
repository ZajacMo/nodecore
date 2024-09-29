-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, tostring, vector
    = math, minetest, nodecore, tostring, vector
local math_pi
    = math.pi
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local vec_to_dir = nodecore.vector_to_dir
local huddots = nodecore.rotation_hud_dots

local transform_by_scrkey = {
	["0-1"] = "I",
	["10"] = "R270",
	["01"] = "R180",
	["-10"] = "R90",
}

nodecore.register_playerstep({
		label = "rotation scan",
		action = function(player, data)
			if player:get_player_control().sneak then
				huddots(player)
				return nodecore.hud_set(player, {
						label = modname,
						ttl = 0,
					})
			end

			local pt = data.raycast()

			local _, _, rot = nodecore.rotation_compute(player, pt)
			if not rot then
				huddots(player)
			end
			if not (rot and rot.param2) then
				return nodecore.hud_set(player, {
						label = modname,
						ttl = 0,
					})
			end
			huddots(player, rot.facectr, pt.intersection_normal)

			if not rot.rotdir then
				return nodecore.hud_set(player, {
						label = modname,
						hud_elem_type = "image_waypoint",
						text = "nc_api_rotate_hudarrow_long.png",
						scale = {x = 1, y = 1},
						world_pos = rot.facectr,
						precision = 0,
					})
			end

			local lookdir = player:get_look_dir()
			local camrt = minetest.yaw_to_dir(player:get_look_horizontal() - math_pi / 2)
			local camup = vector.cross(camrt, lookdir)
			local function screenspace(p)
				return vector.new(vector.dot(p, camrt), vector.dot(p, camup), 0)
			end
			local scrrot = screenspace(rot.rotdir)
			local scrnorm = screenspace(pt.intersection_normal)

			local txr = nodecore.tmod("nc_api_rotate_hudarrow_short.png")
			if vec_to_dir(vector.cross(scrrot, scrnorm)).z > 0 then
				txr = txr:transform("FX")
			end
			do
				local r = vec_to_dir(scrrot)
				txr = txr:transform(transform_by_scrkey[r.x .. r.y])
			end

			return nodecore.hud_set(player, {
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
