-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type, vector
    = minetest, nodecore, type, vector
-- LUALOCALS > ---------------------------------------------------------

local touched = {}

local function nodeface(pt)
	return vector.multiply(vector.add(
			pt.under, pt.above), 0.5)
end

nodecore.register_on_punchnode("touchtip on punch", function(_, _, player, pt)
		if not player then return end
		local pname = player:get_player_name()
		if not pname then return end
		touched[pname] = nodeface(pt)
	end)

local function settip(player, pos, name)
	if not pos then
		return nodecore.hud_set_multiline(player, {
				label = "looktip",
				ttl = 0
			}, nil, "name")
	end
	local pname = player:get_player_name()
	local tp = touched[pname]
	if tp and not vector.equals(tp, pos) then
		touched[pname] = nil
	end
	return nodecore.hud_set_multiline(player, {
			label = "looktip",
			hud_elem_type = "waypoint",
			world_pos = pos,
			name = name,
			text = "",
			precision = 0,
			number = 0xffffff,
			z_index = -250,
			quick = true
		}, nodecore.translate, "name")
end

nodecore.register_playerstep({
		label = "looktip",
		priority = -100,
		action = function(player, data, dtime)
			local ctl = data.control
			if ctl.up or ctl.down or ctl.left or ctl.right or ctl.jump then
				data.looktip_time = 0
				return settip(player)
			end
			data.looktip_time = (data.looktip_time or 0) + dtime
			if data.looktip_time < 0.4 then return end
			local pt = data.raycast()
			if pt then
				if pt.type == "node" then
					local llu = nodecore.get_node_light(pt.under) or 0
					local lla = nodecore.get_node_light(pt.above) or 0
					local ll = (llu > lla) and llu or lla
					if ll <= 0 then
						local pname = player:get_player_name()
						local tp = touched[pname]
						if tp and vector.equals(tp, nodeface(pt)) then
							ll = 1
						end
					end
					if ll <= 0 then return settip(player) end
					data.pointing = "node"
					return settip(player, nodeface(pt),
						nodecore.touchtip_node(
							pt.under,
							minetest.get_node(pt.under),
							player,
							pt))
				elseif pt.type == "object" then
					local ll = nodecore.get_node_light(
						pt.ref:get_pos()) or 0
					if ll >= 0 then
						data.pointing = "obj"
						local luent = pt.ref:get_luaentity()
						local desc = luent and luent.description
						if desc then
							if type(desc) == "function" then
								desc = desc(luent)
							end
							return settip(player,
								pt.ref:get_pos(),
								desc)
						end
					end
					return
				end
			end
			return settip(player)
		end
	})
