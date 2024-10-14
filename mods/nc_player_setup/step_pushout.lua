-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, string, type, vector
    = core, math, nc, pairs, string, type, vector
local math_random, string_format
    = math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local mintime = 2
local stepdist = 16

local function normalbox(box)
	if not box then return true end
	if type(box) ~= "table" then return end
	if box.fixed then return normalbox(box.fixed) end
	if #box == 1 then return normalbox(box[1]) end
	return box[1] == -0.5 and box[2] == -0.5 and box[3] == -0.5
	and box[4] == 0.5 and box[5] == 0.5 and box[6] == 0.5
end

local function ispushout(def, head)
	if def.liquidtype ~= "none" then return head and def.pointable end
	if not def.walkable then return end
	if def.groups and def.groups.is_stack_only then return end
	return normalbox(def.collision_box)
end

local headsolids = {}
local footsolids = {}
core.after(0, function()
		for k, v in pairs(core.registered_nodes) do
			headsolids[k] = ispushout(v, true) or nil
			footsolids[k] = ispushout(v, false) or nil
		end
		headsolids.ignore = nil
		footsolids.ignore = nil
	end)

local function isroomcheck(pos, solids)
	local nodename = core.get_node(pos).name
	if nodename == "ignore" then
		-- Ignores outside the map should push the player back toward
		-- the map area. Ignores inside the map are not yet loaded and we
		-- shouldn't push the player around until we find out what they are.
		return not nc.within_map_limits(pos)
	end
	return solids[nodename]
end

local function isroom(pos)
	return not (isroomcheck(pos, footsolids)
		or isroomcheck({
				x = pos.x,
				y = pos.y + 1,
				z = pos.z
			}, headsolids))
end

nc.room_for_player = isroom

nc.player_pushout_disable = nc.player_pushout_disable or function() end

local function bias(n)
	return n + ((n > 0) and math_random(-stepdist - 1, stepdist - 1)
		or math_random(-stepdist + 1, stepdist + 1))
end

nc.register_playerstep({
		label = "push player out of solids",
		action = function(player, data, dtime)
			local function reset() data.pushout = nil end

			if player:get_attach() then return reset() end

			if data.control.up or data.control.down
			or data.control.left or data.control.right
			or data.control.sneak or data.control.jump
			then return reset() end

			if core.get_player_privs(player).noclip
			or nc.player_pushout_disable(player, data)
			then return reset() end

			local pos = vector.round(player:get_pos())
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
					nc.addphealth(player, -dist + 1, {
							nc_type = "pushout"
						})
				end
				newpos.y = newpos.y - 0.49
				nc.log("action", string_format("%s pushed out of"
						.. " solid from %s to %s",
						data.pname,
						core.pos_to_string(pos),
						core.pos_to_string(newpos)))
				newpos.keepinv = true
				player:set_pos(newpos)
				return reset()
			end

			for rel in nc.settlescan() do
				local p = vector.add(pos, rel)
				if isroom(p) then
					return pushto(p)
				end
			end

			local spawn = nc.spawn_point()
			local rel = vector.subtract(pos, spawn)
			rel = {
				x = bias(rel.x),
				y = bias(rel.y),
				z = bias(rel.z)
			}
			return pushto(vector.add(rel, spawn))
		end
	})
