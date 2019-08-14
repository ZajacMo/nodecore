-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local tilemods = {
	{idx = 1, part = "end", tran = "R180"},
	{idx = 2, part = "end", tran = "FX"},
	{idx = 3, part = "side", tran = "I"},
	{idx = 6, part = "side", tran = "R180"}
}

function nodecore.register_door(basemod, basenode, ext)
	local basefull = basemod .. ":" .. basenode
	local basedef = minetest.registered_nodes[basefull]

	local tiles = nodecore.underride({}, basedef.tiles)
	while #tiles < 6 do tiles[#tiles + 1] = tiles[#tiles] end
	for k, v in pairs(tiles) do tiles[k] = v.name or v end
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^nc_doors_hinge_" .. v.part
		.. "_base.png^[transform" .. v.tran
	end

	local paneldef = nodecore.underride(ext or {}, {
		name = modname .. ":panel_" .. basenode,
		tiles = tiles,
		paramtype2 = "facedir",
		on_rightclick = nodecore.node_spin_filtered(function(a, b)
			return vector.equals(a.f, b.r)
			and vector.equals(a.r, b.f)
		end),
	}, basedef)

	minetest.register_node(paneldef.name, paneldef)

	local tiles = nodecore.underride({}, tiles)
	for _, v in pairs(tilemods) do
		tiles[v.idx] = tiles[v.idx] .. "^(nc_lode_tempered.png^[mask:(nc_doors_hinge_" .. v.part
		.. "_mask.png^[transform" .. v.tran .. "))"
	end

	local doordef = nodecore.underride({
		name = modname .. ":door_" .. basenode,
		tiles = tiles,
		drop = "nc_lode:rod_tempered",
		drop_in_place = paneldef.name
	}, paneldef)

	minetest.register_node(doordef.name, doordef)

	nodecore.register_craft({
		label = "drill door " .. basenode:lower(),
		action = "pummel",
		toolgroups = {thumpy = 3},
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
		label = "door pin " .. basenode:lower(),
		action = "pummel",
		toolgroups = {thumpy = 1},
		nodes = {
			{
				match = "nc_lode:rod_tempered",
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

nodecore.register_door("nc_woodwork", "plank")
