-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string, type, vector
    = math, minetest, nodecore, pairs, string, type, vector
local math_random, string_format
    = math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local mintime = nodecore.setting_float(modname .. "_time", 2,
	"Push out of solid time", [[The amount of time a player
	needs to be trapped in a solid node before being pushed out.]])
local stepdist = nodecore.setting_float(modname .. "_stepdist", 5,
	"Push out of solid distance", [[The maximum distance in
	nodes that a player will be pushed out of solids.]])

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
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			headsolids[k] = ispushout(v, true) or nil
			footsolids[k] = ispushout(v, false) or nil
		end
		headsolids.ignore = nil
		footsolids.ignore = nil
	end)

local function isroom(pos)
	return not (footsolids[minetest.get_node(pos).name]
		or headsolids[minetest.get_node({
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

			if data.control.up or data.control.down
			or data.control.left or data.control.right
			or data.control.sneak or data.control.jump
			then return reset() end

			if minetest.get_player_privs(player).noclip
			or nodecore.player_pushout_disable(player, data)
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
					nodecore.addphealth(player, -dist + 1, {
							nc_type = "pushout"
						})
				end
				newpos.y = newpos.y - 0.49
				nodecore.log("action", string_format("%s pushed out of"
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
