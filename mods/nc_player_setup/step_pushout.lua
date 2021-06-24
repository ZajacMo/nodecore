-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, tonumber, type, vector
    = math, minetest, nodecore, pairs, string, tonumber, type, vector
local math_random, string_format
    = math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local mintime = tonumber(minetest.settings:get(nodecore.product:lower() .. "_pushout_time")) or 2
local stepdist = tonumber(minetest.settings:get(nodecore.product:lower() .. "_pushout_stepdist")) or 5

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

nodecore.player_pushout_disable = nodecore.player_pushout_disable or function() end

nodecore.register_playerstep({
		label = "push player out of solids",
		action = function(player, data, dtime)
			local function reset() data.pushout = nil end

			if minetest.check_player_privs(player, "noclip")
			or nodecore.player_pushout_disable(player, data)
			then return reset() end

			local pos = player:get_pos()
			pos.y = pos.y + 0.01
			pos = vector.round(pos)
			if isroom(pos) then return reset() end

			local podata = data.pushout or {}
			local oldpos = podata.pos or pos
			if not vector.equals(pos, oldpos) then return reset() end

			local pt = (podata.time or 0) + dtime
			if pt < mintime then
				data.pushout = {time = pt, pos = pos}
				return
			end

			local function pushto(newpos)
				local dist = vector.distance(pos, newpos)
				if dist > 1 then
					nodecore.addphealth(player, -dist + 1, {
							nc_type = "pushout"
						})
				end
				newpos.y = newpos.y - 0.49
				nodecore.log("action", string_format("player %q pushed out of"
						.. " solid from %s to %s",
						data.pname,
						minetest.pos_to_string(pos),
						minetest.pos_to_string(newpos)))
				newpos.keepinv = true
				player:set_pos(newpos)
				return reset()
			end

			for rel in nodecore.settlescan() do
				local p = vector.add(pos, rel)
				if isroom(p) then
					return pushto(p)
				end
			end
			local function bias(n)
				return n + ((n > 0) and math_random(-stepdist - 1, stepdist - 1)
					or math_random(-stepdist + 1, stepdist + 1))
			end
			return pushto({
					x = bias(pos.x),
					y = bias(pos.y),
					z = bias(pos.z)
				})
		end
	})
