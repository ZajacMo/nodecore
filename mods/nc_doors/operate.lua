-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local hashpos = minetest.pos_to_string

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

local function set_node(pos, node)
	local exists = minetest.get_node(pos)
	if exists.name ~= node.name
	or exists.param ~= node.param
	or exists.param2 ~= node.param2 then
		return minetest.set_node(pos, node)
	end
end

local squelch = {}
nodecore.register_globalstep("door squelch", function(dtime)
		for k, v in pairs(squelch) do
			squelch[k] = (v > dtime) and (v - dtime) or nil
		end
	end)

local is_door = {groups = {door = true}}

function nodecore.operate_door(pos, node, dir)
	local key = hashpos(pos)
	if squelch[key] then return end

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
	if nodecore.scan_flood(pos, 128, function(p)
			local n = minetest.get_node_or_nil(p)
			if not n then return true end
			if (not nodecore.match(n, is_door))
			or (not vector.equals(hingeaxis(p, n), hinge)) then return false end
			found[hashpos(p)] = {pos = p, node = n}
		end
	) then return end

	local press
	local toop = {}
	for k, v in pairs(found) do
		local ffd = nodecore.facedirs[v.node.param2 or 0]
		v.dir = ffd[rotdir]
		v.dir2 = rotdir == "r" and ffd.k or ffd.l
		local to = vector.add(v.pos, v.dir)

		if (not found[hashpos(to)])
		and (not nodecore.buildable_to(to))
		then
			if press then return end
			press = {
				pos = to,
				dir = v.dir,
				from = v
			}
		end

		if nodecore.obstructed(to) then return end

		local str = hashpos(to)
		if squelch[str] then return end

		v.str = str
		v.to = to
		v.fd = ffd

		toop[k .. "l"] = {
			pos = vector.add(v.pos, ffd.l),
			dir = rotdir == "r" and ffd.k or ffd.f,
			from = v
		}
		toop[k .. "k"] = {
			pos = vector.add(v.pos, ffd.k),
			dir = rotdir == "r" and ffd.r or ffd.l,
			from = v
		}
	end
	if press then
		local data = {
			action = "press",
			pointed = {
				["type"] = "node",
				above = vector.subtract(press.pos, press.dir),
				under = press.pos
			},
			axis = hinge
		}
		if nodecore.craft_check(press.pos, minetest.get_node(press.pos), data) then
			nodecore.sound_play("nc_doors_operate",
				{pos = press.pos, gain = 0.5})
			return true
		end
		return
	end

	local toset = {}
	for k, v in pairs(found) do
		toset[k] = {pos = v.pos, name = "air", param2 = 0}
		squelch[k] = 0.5
		squelch[v.str] = 0.5
	end
	for _, v in pairs(found) do
		for i, xfd in pairs(nodecore.facedirs) do
			if vector.equals(xfd.t, v.fd.t)
			and vector.equals(xfd.r, rotdir == "r" and v.fd.f or v.fd.k) then
				toset[hashpos(v.to)] = {
					pos = v.to,
					name = v.node.name,
					param2 = i
				}
				break
			end
		end
	end

	for _, v in pairs(toset) do
		set_node(v.pos, v)
		if v.name ~= "air" then
			local p = vector.round(vector.multiply(v.pos, 0.25))
			local k = "sfx" .. hashpos(p)
			if not squelch[k] then
				squelch[k] = 0
				nodecore.sound_play("nc_doors_operate",
					{pos = v.pos, gain = 0.5})
			end
		else
			nodecore.fallcheck({x = pos.x, y = pos.y + 1, z = pos.z})
		end
	end
	for _, v in pairs(found) do
		nodecore.door_push({x = v.pos.x, y = v.pos.y + 1, z = v.pos.z}, v.dir, v.dir2)
	end
	for _, v in pairs(toop) do
		nodecore.operate_door(v.pos, nil, v.dir)
		nodecore.door_push(v.pos, v.dir)
	end
	return true
end
