-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local solids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.walkable and not v.climbable and v.liquidtype == "none" then
				solids[k] = true
			end
		end
		solids.ignore = nil
	end)

local function isroom(pos)
	return not (solids[minetest.get_node(pos).name]
		or solids[minetest.get_node({
				x = pos.x,
				y = pos.y + 1,
				z = pos.z
			}).name])
end

nodecore.register_playerstep({
		label = "push player out of solids",
		action = function(player, data, dtime)
			if minetest.check_player_privs(player, "noclip") then
				data.pushout = 0
				return
			end
			local pos = vector.round(player:get_pos())
			if isroom(pos) then
				data.pushout = 0
				return
			end

			data.pushout = (data.pushout or 0) + dtime
			if data.pushout < 1 then return end

			local function pushto(newpos)
				local dist = vector.distance(pos, newpos)
				if dist > 1 then
					nodecore.addphealth(player, -dist + 1, {
							nc_type = "pushout"
						})
				end
				return player:set_pos(newpos)
			end

			for rel in nodecore.settlescan() do
				local p = vector.add(pos, rel)
				if isroom(p) then
					return pushto(p)
				end
			end
			return pushto({
					x = pos.x + math_random(-5, 5),
					y = pos.y + math_random(-3, 7),
					z = pos.z + math_random(-5, 5)
				})
		end
	})
