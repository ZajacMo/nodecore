-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type, vector
    = minetest, nodecore, type, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local looktip_after = nodecore.setting_float(modname .. "_looktip_time", 0.4,
	"LookTip Delay Time", [[The number of seconds a player must be
	standing still, or focused on one node face, to trigger a LookTip.]])

local touched_faces = {}

local function nodeface(pt)
	return vector.multiply(vector.add(
			pt.under, pt.above), 0.5)
end

nodecore.register_on_punchnode("touchtip on punch", function(_, _, player, pt)
		if not player then return end
		local pname = player:get_player_name()
		if not pname then return end
		touched_faces[pname] = nodeface(pt)
	end)

local function settip(player, pos, name)
	if not pos then
		return nodecore.hud_set_multiline(player, {
				label = "looktip",
				ttl = 0
			}, nil, "name")
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

local function checknode(player, pt, data)
	if not nodecore.within_map_limits(pt.under) then return end

	local face = nodeface(pt)

	local pname = player:get_player_name()
	local tp = touched_faces[pname]
	if tp and vector.equals(tp, face) then return true end
	if tp then touched_faces[pname] = nil end

	local llu = nodecore.get_node_light(pt.under) or 0
	local lla = nodecore.get_node_light(pt.above) or 0
	local ll = (llu > lla) and llu or lla
	if ll <= 0 then return end

	if data.looktip_stoptime <= nodecore.gametime then return true end

	local old = data.looktip_focus
	data.looktip_focus = face
	data.looktip_focustime = old and vector.equals(old, face)
	and data.looktip_focustime or nodecore.gametime + looktip_after
	return data.looktip_focustime <= nodecore.gametime
end

nodecore.register_playerstep({
		label = "looktip",
		priority = -100,
		action = function(player, data)
			local ctl = data.control
			data.looktip_stoptime = (not (ctl.up or ctl.down or ctl.left
					or ctl.right or ctl.jump)) and data.looktip_stoptime
			or nodecore.gametime + looktip_after

			local pt = data.raycast()
			if not pt then return settip(player) end
			if pt.type == "node" then
				if checknode(player, pt, data) then
					return settip(player, nodeface(pt),
						nodecore.touchtip_node(
							pt.under,
							minetest.get_node(pt.under),
							player,
							pt))
				end
			elseif pt.type == "object" then
				local ll = nodecore.get_node_light(
					pt.ref:get_pos()) or 0
				if ll <= 0 then return settip(player) end
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
			return settip(player)
		end
	})
