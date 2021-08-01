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

local default_range = 4

nodecore.register_playerstep({
		label = "looktip",
		priority = -100,
		action = function(player, data)
			data.pointing = nil

			local pos = player:get_pos()
			pos.y = pos.y + player:get_properties().eye_height
			local look = player:get_look_dir()
			local wield = minetest.registered_items[player
			:get_wielded_item():get_name()]
			local range = wield and wield.range or default_range
			local target = vector.add(pos, vector.multiply(look, range))

			for pt in minetest.raycast(pos, target, true, false) do
				if pt.type == "node" then
					local llu = nodecore.get_node_light(pt.under) or 0
					local lla = nodecore.get_node_light(pt.above) or 0
					local ll = (llu > lla) and llu or lla
					if ll <= 0 then
						local pname = player:get_player_name()
						local tp = touched[pname]
						if tp and vector.equals(tp, pt.under) then
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
				elseif pt.type == "object" and pt.ref ~= player and pt.ref:get_attach() ~= player then
					local ll = nodecore.get_node_light(
						pt.ref:get_pos()) or 0
					if ll >= 0 then
						data.pointing = "obj"
						local luent = pt.ref:get_luaentity()
						local desc = luent.description
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
