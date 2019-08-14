-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

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

local squelch = {}
minetest.register_globalstep(function() squelch = {} end)

local is_door = {groups = { door = true }}

function nodecore.operate_door(pos, node, dir)
	if squelch[minetest.pos_to_string(pos)] then return end
	node = node or minetest.get_node_or_nil(pos)
	if (not node) or (not nodecore.match(node, is_door)) then return end

	local fd = nodecore.facedirs[node.param2 or 0]
	local rotdir
	if vector.equals(dir, fd.k) or vector.equals(dir, fd.r) then
		rotdir = "r"
	elseif vector.equals(dir, fd.l) or vector.equals(dir, fd.f) then
		rotdir = "f"
	else return end

	local found = {}
	local hinge = hingeaxis(pos, node)
	if nodecore.scan_flood(pos, 128, function(p, d)
		local n = minetest.get_node_or_nil(p)
		if not n then return true end
		if (not nodecore.match(n, is_door))
		or (not vector.equals(hingeaxis(p, n), hinge)) then return false end
		found[minetest.pos_to_string(p)] = {pos = p, node = n}
	end) then return end

	local toop = {}
	for k, v in pairs(found) do
		local fd = nodecore.facedirs[v.node.param2 or 0]
		local to = vector.add(v.pos, fd[rotdir])

		if (not found[minetest.pos_to_string(to)])
		and (not nodecore.buildable_to(to))
		then return end

		local str = minetest.pos_to_string(to)
		if squelch[str] then return end

		v.str = str
		v.to = to
		v.fd = fd

		toop[k .. "l"] = {
			pos = vector.add(v.pos, fd.l),
			dir = rotdir == "r" and fd.k or fd.f
		}
		toop[k .. "k"] = {
			pos = vector.add(v.pos, fd.k),
			dir = rotdir == "r" and fd.r or fd.l
		}
	end

	local toset = {}
	for k, v in pairs(found) do
		toset[k] = {pos = v.pos, name = "air"}
		squelch[k] = true
		squelch[v.str] = true
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
		if v.name ~= "air" then
			local p = vector.round(vector.multiply(v.pos, 0.25))
			local k = "sfx" .. minetest.pos_to_string(p)
			if not squelch[k] then
				squelch[k] = true
				minetest.sound_play("nc_doors_operate",
					{pos = v.pos, gain = 0.5})
			end
		end
	end
	for k, v in pairs(toop) do
		nodecore.operate_door(v.pos, nil, v.dir)
	end
end
