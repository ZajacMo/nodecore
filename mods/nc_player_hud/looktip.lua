-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local touched = {}

nodecore.register_on_punchnode("touchtip on punch", function(pos, _, puncher)
		if not puncher then return end
		local pname = puncher:get_player_name()
		if not pname then return end
		touched[pname] = pos
	end)

local function settip(player, pt)
	local pname = player:get_player_name()
	local tp = touched[pname]
	if (not pt) or (tp and not vector.equals(tp, pt.under)) then
		touched[pname] = nil
	end
	if not pt then
		return nodecore.hud_set_multiline(player, {
				label = "looktip",
				ttl = 0
			}, nil, "name")
	end
	return nodecore.hud_set_multiline(player, {
			label = "looktip",
			hud_elem_type = "waypoint",
			world_pos = vector.multiply(vector.add(
					pt.under, pt.above), 0.5),
			name = nodecore.touchtip_node(
				pt.under,
				minetest.get_node(pt.under),
				player,
				pt),
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
			if not nodecore.interact(player) then return settip(player) end

			local pos = player:get_pos()
			pos.y = pos.y + player:get_properties().eye_height
			local look = player:get_look_dir()
			local wield = minetest.registered_items[player:get_wielded_item():get_name()]
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
					return settip(player, pt)
				elseif pt.type == "object" and pt.ref ~= player
					and pt.ref:get_attach() ~= player then
						data.pointing = "obj"
						return
					end
				end
				return settip(player)
			end
		})
