-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, type, vector
    = math, minetest, nodecore, pairs, type, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local function normalbox(box)
	if not box then return true end
	if type(box) ~= "table" then return end
	if box.fixed then return normalbox(box.fixed) end
	if #box == 1 then return box[1] end
	return box[1] == -0.5 and box[2] == -0.5 and box[3] == -0.5
	and box[4] == 0.5 and box[5] == 0.5 and box[6] == 0.5
end

local solids = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.walkable and v.liquidtype == "none"
			and normalbox(v.collision_box) then
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
			local function bias(n)
				return n + ((n > 0) and math_random(-6, 4)
					or math_random(-4, 6))
			end
			return pushto({
					x = bias(pos.x),
					y = bias(pos.y),
					z = bias(pos.z)
				})
		end
	})
