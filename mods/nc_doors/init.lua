-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function hingeaxis(pos, node)
	local fd = node and node.param2 or 0
	fd = nodecore.facedirs[fd]
	fd = vector.multiply(vector.add(fd.f, fd.r), 0.5)
	return {
		x = fd.x == 0 and 0 or pos.x + fd.x,
		y = fd.y == 0 and 0 or pos.y + fd.y,
		z = fd.z == 0 and 0 or pos.z + fd.z
	}
end

local function doorop(pos, node, _, _, pointed)
	if (not pointed.above) or (not pointed.under) then return end
	
	local force = vector.subtract(pointed.under, pointed.above)
	local fd = nodecore.facedirs[node.param2 or 0]
	local rotdir
	if vector.equals(force, fd.k) or vector.equals(force, fd.r) then
		rotdir = "r"
	elseif vector.equals(force, fd.l) or vector.equals(force, fd.f) then
		rotdir = "f"
	else return end

	local found = {}
	local hinge = hingeaxis(pos, node)
	if nodecore.scan_flood(pos, 128, function(p, d)
		local n = minetest.get_node_or_nil(p)
		if not n then return true end
		if (not nodecore.match(n, {groups = {door = true}}))
		or (not vector.equals(hingeaxis(p, n), hinge)) then return false end
		found[minetest.pos_to_string(p)] = {pos = p, node = n}
	end) then return end

	for k, v in pairs(found) do
		local fd = nodecore.facedirs[v.node.param2 or 0]
		local to = vector.add(v.pos, fd[rotdir])
		if (not found[minetest.pos_to_string(to)])
		and (not nodecore.buildable_to(to))
		then return end
		v.to = to
		v.fd = fd
	end

	local toset = {}
	for k, v in pairs(found) do
		toset[k] = {pos = v.pos, name = "air"}
	end
	for k, v in pairs(found) do
		for i, fd in pairs(nodecore.facedirs) do
			if vector.equals(fd.t, v.fd.t)
			and vector.equals(fd.r, rotdir == "r" and v.fd.f or v.fd.k) then
				toset[minetest.pos_to_string(v.to)] = {
					pos = v.to,
					name = v.node.name,
					param2 = i
				}
				break
			end
		end
	end

	for k, v in pairs(toset) do
		minetest.set_node(v.pos, v)
	end
end

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
		description = basedef.description .. " Panel",
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

	local groups = nodecore.underride({door = 1}, basedef.groups)
	local doordef = nodecore.underride({
		name = modname .. ":door_" .. basenode,
		description = basedef.description .. " Door",
		tiles = tiles,
		drop = "nc_lode:rod_tempered",
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
		label = "door pin " .. basenode:lower(),
		action = "pummel",
		toolgroups = {thumpy = 1},
		normal = {y = 1},
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
