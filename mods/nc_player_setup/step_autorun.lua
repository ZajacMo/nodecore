-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_pi, math_sin
    = math.pi, math.sin
-- LUALOCALS > ---------------------------------------------------------

local autorun_walkspeed = 1.25
local autorun_walktime = 2
local autorun_acceltime = 4
local autorun_ratio = 2

local function solid(pos)
	local node = core.get_node(pos)
	local def = core.registered_items[node.name]
	if not def then return true end
	return def.liquidtype == "none" and def.walkable
end

local hurttime = {}
nc.register_on_player_hpchange(function(player, hp)
		if hp >= 0 then return end
		if not nc.player_can_take_damage(player) then return end
		hurttime[player:get_player_name()] = nc.gametime
	end)

nc.register_playerstep({
		label = "autorun",
		action = function(player, data)
			local ctl = data.control
			local walking = ctl.up and not ctl.down
			if (not walking) and ctl.jump and (not ctl.sneak) then
				local ppos = player:get_pos()
				local def = core.registered_nodes[core.get_node(ppos).name]
				walking = def and (def.climbable or def.liquidtype ~= "none")
				if not walking then
					ppos.y = ppos.y + 1
					def = core.registered_nodes[core.get_node(ppos).name]
					walking = def and (def.climbable or def.liquidtype ~= "none")
				end
			end
			if walking and ctl.sneak then
				local pos = player:get_pos()
				if not solid(pos) then
					pos.y = pos.y - 1
					walking = not solid(pos)
				end
			end
			local speed = autorun_walkspeed
			local max = autorun_walkspeed * autorun_ratio
			if walking and data.autoruntime then
				local ht = hurttime[data.pname]
				if ht and ht > data.autoruntime then data.autoruntime = ht end
				local t = nc.gametime - data.autoruntime - autorun_walktime
				if t > math_pi * autorun_acceltime then
					nc.player_discover(player, "autorun")
					speed = max
				elseif t > 0 then
					local hr = (autorun_ratio - 1) / 2
					speed = autorun_walkspeed * (1 + hr + hr * math_sin(t
							/ autorun_acceltime - math_pi / 2))
				end
			else
				data.autoruntime = nc.gametime
			end
			local oldspeed = data.physics.speed or 0
			if oldspeed > speed or oldspeed < (speed - 0.05)
			or (speed == max and oldspeed ~= max) then
				data.physics.speed = speed
			end
		end
	})
