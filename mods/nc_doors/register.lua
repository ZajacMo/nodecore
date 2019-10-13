-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function doorop(pos, node, clicker, stack, pointed)
	if (not pointed.above) or (not pointed.under) then return end
	local force = vector.subtract(pointed.under, pointed.above)
	local axis = nodecore.hingeaxis(pos, node)
	if (axis.x * force.x ~= 0) or (axis.y * force.y ~= 0)
	or (axis.z * force.z ~= 0) then
		return nodecore.operate_door(pos, node, force)
	end

	local def = stack:get_definition()
	if def.type == "node" and not def.place_as_item then
		local function helper(left, ok, ...)
			if ok then nodecore.node_sound(pointed.above, "place") end
			return left, ok, ...
		end
		return helper(minetest.item_place_node(stack, clicker, pointed))
	end
	if not stack:is_empty() then
		local above = minetest.get_pointed_thing_position(pointed, true)
		if above and nodecore.buildable_to(above) then
			nodecore.place_stack(above, stack:take_item(), clicker, pointed)
		end
	end
end

local tilemods = {
	{idx = 1, part = "end", tran = "R180"},
	{idx = 2, part = "end", tran = "FX"},
	{idx = 3, part = "side", tran = "I"},
	{idx = 6, part = "side", tran = "R180"}
}

function nodecore.register_door(basemod, basenode, desc, pin)
	local basefull = basemod .. ":" .. basenode
	local basedef = minetest.registered_nodes[basefull]

	local tiles = nodecore.underride({}, basedef.tiles)
	while #tiles < 6 do tiles[#tiles + 1] = tiles[#tiles] end
	for k, v in pairs(tiles) do tiles[k] = v.name or v end
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^nc_doors_hinge_" .. v.part
		.. "_base.png^[transform" .. v.tran
	end

	local paneldef = nodecore.underride({}, {
			name = modname .. ":panel_" .. basenode,
			description = (desc or basedef.description) .. " Panel",
			tiles = tiles,
			paramtype2 = "facedir",
			silktouch = false,
			on_rightclick = nodecore.node_spin_filtered(function(a, b)
					return vector.equals(a.f, b.r)
					and vector.equals(a.r, b.f)
				end),
		}, basedef)
	paneldef.drop = nil
	paneldef.alternate_loose = nil
	paneldef.drop_in_place = nil
	paneldef.after_dig_node = nil

	minetest.register_node(paneldef.name, paneldef)

	local t = minetest.registered_items[pin].tiles
	t = t[3] or t[2] or t[1]
	t = t.name or t
	tiles = nodecore.underride({}, tiles)
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^((" .. t .. ")^[mask:nc_doors_hinge_" .. v.part
		.. "_mask.png^[transform" .. v.tran .. ")"
	end

	local groups = nodecore.underride({door = 1}, basedef.groups)
	local doordef = nodecore.underride({
			name = modname .. ":door_" .. basenode,
			description = (desc or basedef.description) .. " Hinged Panel",
			tiles = tiles,
			drop = pin,
			drop_in_place = paneldef.name,
			on_rightclick = doorop,
			groups = groups
		}, paneldef)

	minetest.register_node(doordef.name, doordef)

	nodecore.register_craft({
			label = "drill door " .. basenode:lower(),
			action = "pummel",
			toolgroups = {thumpy = 3},
			normal = {y = 1},
			nodes = {
				{
					match = "nc_lode:rod_tempered",
				},
				{
					y = -1,
					match = basefull,
					replace = paneldef.name
				}
			}
		})

	nodecore.register_craft({
			label = "lubricate door " .. basenode:lower(),
			check = function(_, data)
				return minetest.get_meta(data.rel(0, -1, 0))
				:get_float("doorlube") ~= 1
			end,
			nodes = {
				{
					match = "nc_fire:lump_coal",
					replace = "air"
				},
				{
					y = -1,
					match = paneldef.name,
				}
			},
			after = function(pos, data)
				minetest.get_meta(data.rel(0, -1, 0)):set_float("doorlube", 1)
				return nodecore.digparticles(
					minetest.registered_nodes["nc_fire:coal8"],
					{
						collisiondetection = true,
						amount = 10,
						time = 0.2,
						minpos = {x = pos.x - 0.4, y = pos.y - 0.5, z = pos.z - 0.4},
						maxpos = {x = pos.x + 0.4, y = pos.y - 0.45, z = pos.z + 0.4},
						minexptime = 0.1,
						maxexptime = 1,
						minsize = 1,
						maxsize = 3
					}
				)
			end
		})
	nodecore.register_craft({
			label = "door pin " .. basenode:lower(),
			action = "pummel",
			toolgroups = {thumpy = 1},
			normal = {y = 1},
			check = function(_, data)
				return minetest.get_meta(data.rel(0, -1, 0))
				:get_float("doorlube") == 1
			end,
			nodes = {
				{
					match = pin,
					replace = "air"
				},
				{
					y = -1,
					match = paneldef.name,
					replace = doordef.name
				}
			}
		})
end

nodecore.register_door("nc_woodwork", "plank", "Wooden", "nc_woodwork:staff")
nodecore.register_door("nc_terrain", "cobble", "Cobble", "nc_lode:rod_tempered")
