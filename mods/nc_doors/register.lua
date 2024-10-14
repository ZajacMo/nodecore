-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, pairs, vector
    = ItemStack, core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local function doorop(pos, node, clicker, _, pointed)
	if nc.protection_test(pos, clicker) then return end
	if (not pointed.above) or (not pointed.under) then return end
	local force = vector.subtract(pointed.under, pointed.above)
	nc.operate_door(pos, node, force)
end

local tilemods = {
	{idx = 1, part = "end", tran = "R180"},
	{idx = 2, part = "end", tran = "FX"},
	{idx = 3, part = "side", tran = "I"},
	{idx = 6, part = "side", tran = "R180"}
}

function nc.register_door(basemod, basenode, desc, pin, lv, basedef)
	local basefull = basemod .. ":" .. basenode
	basedef = basedef or core.registered_nodes[basefull]

	local tiles = nc.underride({}, basedef.tiles)
	while #tiles < 6 do tiles[#tiles + 1] = tiles[#tiles] end
	for k, v in pairs(tiles) do tiles[k] = v.name or v end
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^nc_doors_hinge_" .. v.part
		.. "_base.png^[transform" .. v.tran
	end
	local scuff = "^(nc_doors_hinge_scuff.png^[opacity:"
	.. (basedef.groups.nc_door_scuff_opacity or 64)
	tiles[4] = tiles[4] .. scuff .. ")"
	tiles[5] = tiles[5] .. scuff .. "^[transformR180)"

	local doorname = modname .. ":door_" .. basenode
	local groups = nc.underride({
			door_panel = lv,
			nc_api_rotate_under = 1,
		}, basedef.groups)
	local paneldef = nc.underride({}, {
			name = modname .. ":panel_" .. basenode,
			description = (desc or basedef.description) .. " Panel",
			tiles = tiles,
			paramtype2 = "facedir",
			silktouch = false,
			groups = groups,
			nc_param2_equivalent = function(a, b)
				return vector.equals(a.f, b.r)
				and vector.equals(a.r, b.f)
			end,
			nc_rotate_allow = function(_, _, clicker)
				return clicker:get_wielded_item():get_name() ~= pin
			end,
			on_rightclick = function(pos, node, clicker, stack, pointed)
				if nc.protection_test(pos, clicker) then return end
				stack = stack and ItemStack(stack)
				if (not stack) or (stack:get_name() ~= pin) then
					return nc.rotation_apply(clicker, pointed)
				end
				local fd = node and node.param2 or 0
				fd = nc.facedirs[fd]
				local dir = vector.subtract(pointed.above, pointed.under)
				if vector.equals(dir, fd.t) or vector.equals(dir, fd.b) then
					node.name = doorname
					nc.player_discover(clicker, "craft:door pin "
						.. basenode:lower())
					nc.set_loud(pos, node)
					stack:take_item(1)
					return stack
				end
			end
		}, basedef)
	paneldef.drop = nil
	paneldef.alternate_loose = nil
	paneldef.drop_in_place = nil
	paneldef.after_dig_node = nil

	core.register_node(":" .. paneldef.name, paneldef)

	local t = core.registered_items[pin].tiles
	t = t[3] or t[2] or t[1]
	t = t.name or t
	tiles = nc.underride({}, tiles)
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^((" .. t .. ")^[mask:nc_doors_hinge_" .. v.part
		.. "_mask.png^[transform" .. v.tran .. ")"
	end

	groups = nc.underride({
			door = lv,
			nc_api_rotate_under = 0,
		}, basedef.groups)
	local doordef = nc.underride({
			name = doorname,
			description = (desc or basedef.description) .. " Hinged Panel",
			tiles = tiles,
			drop = pin,
			drop_in_place = paneldef.name,
			on_rightclick = doorop,
			groups = groups
		}, paneldef)

	core.register_node(":" .. doordef.name, doordef)

	nc.register_craft({
			label = "drill door " .. basenode:lower(),
			action = "pummel",
			toolgroups = {thumpy = 3},
			normal = {y = 1},
			indexkeys = {"group:chisel"},
			nodes = {
				{
					match = {
						lode_temper_tempered = true,
						groups = {chisel = 2}
					},
					dig = true
				},
				{
					y = -1,
					match = basefull,
					replace = paneldef.name
				}
			}
		})
end

nc.register_door("nc_woodwork", "plank", "Wooden", "nc_woodwork:staff", 2)
nc.register_door("nc_terrain", "cobble", "Cobble", "nc_lode:rod_tempered", 3)

nc.register_on_register_item({
		retroactive = true,
		func = function(name, def)
			if def.groups and def.groups.stone_bricks == 2
			and not (def.groups.door or def.groups.door_panel) then
				nc.register_door(
					name:gsub(":.*", ""),
					name:gsub(".*:", ""),
					def.description:gsub("Bricks", "Brick"),
					"nc_lode:rod_tempered",
					4,
					def
				)
			end
		end
	})
