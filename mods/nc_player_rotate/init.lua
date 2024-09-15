-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, tostring, type, vector
    = math, minetest, nodecore, tostring, type, vector
local math_abs, math_pi
    = math.abs, math.pi
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local function vec_to_dir(p)
	local ax = math_abs(p.x)
	local ay = math_abs(p.y)
	local az = math_abs(p.z)
	return ay > ax and ay > az
	and vector.new(0, p.y < 0 and -1 or 1, 0)
	or ax > az
	and vector.new(p.x < 0 and -1 or 1, 0, 0)
	or vector.new(0, 0, p.z < 0 and -1 or 1)
end

local rotvector = {}
minetest.register_on_leaveplayer(function(player)
		rotvector[player] = nil
	end)

function nodecore.get_player_rotate_vector(player)
	player = type(player) == "string" and player or player:get_player_name()
	return rotvector[player]
end

local transform_by_scrkey = {
	["0-1"] = "I",
	["10"] = "R270",
	["01"] = "R180",
	["-10"] = "R90",
}

nodecore.register_playerstep({
		label = "rotation scan",
		action = function(player, data)
			local pname = player:get_player_name()
			local pt = data.raycast()

			if not (pt and pt.above and pt.under and pt.intersection_point
				and pt.intersection_normal) then
				rotvector[pname] = nil
				return nodecore.hud_set(player, {
						label = modname,
						ttl = 0,
						quick = true
					})
			end

			local facectr = vector.multiply(vector.add(pt.above, pt.under), 0.5)
			local facerel = vector.subtract(pt.intersection_point, facectr)

			if facerel.x > -1/4 and facerel.x < 1/4
			and facerel.y > -1/4 and facerel.y < 1/4
			and facerel.z > -1/4 and facerel.z < 1/4
			then
				rotvector[data.pname] = vector.multiply(pt.intersection_normal, -1)
				return nodecore.hud_set(player, {
						label = modname,
						hud_elem_type = "image_waypoint",
						text = "nc_player_rotate_hudarrow_long.png",
						scale = {x = 1, y = 1},
						world_pos = facectr,
						precision = 0,
						quick = true
					})
			end

			local rotdir = vec_to_dir(facerel)
			rotvector[data.pname] = vector.cross(pt.intersection_normal, rotdir)

			local lookdir = player:get_look_dir()
			local camrt = minetest.yaw_to_dir(player:get_look_horizontal() - math_pi / 2)
			local camup = vector.cross(camrt, lookdir)
			local function screenspace(p)
				return vector.new(vector.dot(p, camrt), vector.dot(p, camup), 0)
			end
			local scrrot = screenspace(rotdir)
			local scrnorm = screenspace(pt.intersection_normal)

			local txr = nodecore.tmod("nc_player_rotate_hudarrow_short.png")
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
					world_pos = vector.add(facectr, vector.multiply(rotdir, 0.4)),
					precision = 0,
					quick = true
				})
		end
	})
