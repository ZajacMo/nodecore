-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, vector
    = ItemStack, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function doorop(pos, node, _, _, pointed)
	if (not pointed.above) or (not pointed.under) then return end
	local force = vector.subtract(pointed.under, pointed.above)
	nodecore.operate_door(pos, node, force)
end

local tilemods = {
	{idx = 1, part = "end", tran = "R180"},
	{idx = 2, part = "end", tran = "FX"},
	{idx = 3, part = "side", tran = "I"},
	{idx = 6, part = "side", tran = "R180"}
}

function nodecore.register_door(basemod, basenode, desc, pin, lv)
	local basefull = basemod .. ":" .. basenode
	local basedef = minetest.registered_nodes[basefull]

	local tiles = nodecore.underride({}, basedef.tiles)
	while #tiles < 6 do tiles[#tiles + 1] = tiles[#tiles] end
	for k, v in pairs(tiles) do tiles[k] = v.name or v end
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^nc_doors_hinge_" .. v.part
		.. "_base.png^[transform" .. v.tran
	end

	local spin = nodecore.node_spin_filtered(function(a, b)
			return vector.equals(a.f, b.r)
			and vector.equals(a.r, b.f)
		end)

	local doorname = modname .. ":door_" .. basenode
	local paneldef = nodecore.underride({}, {
			name = modname .. ":panel_" .. basenode,
			description = (desc or basedef.description) .. " Panel",
			tiles = tiles,
			paramtype2 = "facedir",
			silktouch = false,
			on_rightclick = function(pos, node, clicker, stack, pointed, ...)
				stack = stack and ItemStack(stack)
				if (not stack) or (stack:get_name() ~= pin) then
					return spin(pos, node, clicker, stack, pointed, ...)
				end
				local fd = node and node.param2 or 0
				fd = nodecore.facedirs[fd]
				local dir = vector.subtract(pointed.above, pointed.under)
				if vector.equals(dir, fd.t) or vector.equals(dir, fd.b) then
					node.name = doorname
					nodecore.player_stat_add(1, clicker, "craft",
						"door pin " .. basenode:lower())
					nodecore.set_loud(pos, node)
					stack:take_item(1)
					return stack
				end
			end
		}, basedef)
	paneldef.drop = nil
	paneldef.alternate_loose = nil
	paneldef.drop_in_place = nil
	paneldef.after_dig_node = nil

	minetest.register_node(":" .. paneldef.name, paneldef)

	local t = minetest.registered_items[pin].tiles
	t = t[3] or t[2] or t[1]
	t = t.name or t
	tiles = nodecore.underride({}, tiles)
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^((" .. t .. ")^[mask:nc_doors_hinge_" .. v.part
		.. "_mask.png^[transform" .. v.tran .. ")"
	end

	local groups = nodecore.underride({door = lv}, basedef.groups)
	local doordef = nodecore.underride({
			name = doorname,
			description = (desc or basedef.description) .. " Hinged Panel",
			tiles = tiles,
			drop = pin,
			drop_in_place = paneldef.name,
			on_rightclick = doorop,
			groups = groups
		}, paneldef)

	minetest.register_node(":" .. doordef.name, doordef)

	nodecore.register_craft({
			label = "drill door " .. basenode:lower(),
			action = "pummel",
			toolgroups = {thumpy = 3},
			normal = {y = 1},
			indexkeys = {"group:chisel"},
			nodes = {
				{
					match = {
						metal_temper_tempered = true,
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

nodecore.register_door("nc_woodwork", "plank", "Wooden", "nc_woodwork:staff", 2)
nodecore.register_door("nc_terrain", "cobble", "Cobble", "nc_lode:rod_tempered", 3)
