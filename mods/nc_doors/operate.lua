-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()

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

local convey = {}

local function conveytrace(okay, seg, u)
	if u.tkey2 then
		local w = convey[u.tkey2]
		if w then return w end
		if nodecore.buildable_to(u.to2) then
			local ok = (not nodecore.obstructed(u.to2)) or nil
			for x in pairs(seg) do
				okay[x] = ok
			end
			u.to = u.to2
			u.tkey = u.tkey2
			return
		end
	end
	local w = convey[u.tkey]
	if w then return w end
	if nodecore.buildable_to(u.to) then
		local ok = (not nodecore.obstructed(u.to)) or nil
		for x in pairs(seg) do
			okay[x] = ok
		end
	end
end

local function set_node(pos, node)
	local exists = minetest.get_node(pos)
	if exists.name ~= node.name
	or exists.param ~= node.param
	or exists.param2 ~= node.param2 then
		return minetest.set_node(pos, node)
	end
end

minetest.register_globalstep(function()
		local nonheads = {}
		for k, v in pairs(convey) do
			local node = minetest.get_node(v.from)
			if node.name ~= v.node.name
			or node.param ~= v.node.param
			or node.param2 ~= v.node.param2 then
				convey[k] = nil
			else
				if v.tkey2 and (convey[v.tkey2] or nodecore.buildable_to(v.to2)) then
					nonheads[v.tkey2] = true
				else
					nonheads[v.tkey] = true
				end
			end
		end
		local okay = {}
		for k, v in pairs(convey) do
			if not nonheads[k] then
				local seg = {}
				local u = v
				while u do
					seg[u] = true
					u = conveytrace(okay, seg, u)
				end
				for x in pairs(seg) do
					convey[x.fkey] = nil
				end
			end
		end
		for _, v in pairs(convey) do
			okay[v] = true
		end
		convey = {}

		local air = {name = "air"}
		local toset = {}
		for v in pairs(okay) do
			toset[v.fkey] = {pos = v.from, node = air}
		end
		for v in pairs(okay) do
			toset[v.tkey] = {
				pos = v.to,
				node = v.node,
				meta = minetest.get_meta(v.from):to_table()
			}
		end
		for _, v in pairs(toset) do
			set_node(v.pos, v.node)
			if v.meta then
				minetest.get_meta(v.pos):from_table(v.meta)
				nodecore.visinv_update_ents(v.pos)
			end
			nodecore.fallcheck(v.pos)
		end
	end)

local is_falling = {groups = {falling_node = true}}

local function trypush(pos, dir, dir2)
	local node = minetest.get_node(pos)
	if not nodecore.match(node, is_falling) then return end

	local data = {
		from = pos,
		fkey = minetest.hash_node_position(pos),
		to = vector.add(pos, dir),
		node = node,
	}
	data.tkey = minetest.hash_node_position(data.to)
	if dir2 then
		data.to2 = vector.add(pos, dir2)
		data.tkey2 = minetest.hash_node_position(data.to2)
	end
	convey[data.fkey] = data
end

local squelch = modstore:get_string("squelch")
squelch = squelch and squelch ~= "" and minetest.deserialize(squelch) or {}
minetest.register_globalstep(function(dtime)
		for k, v in pairs(squelch) do
			squelch[k] = (v > dtime) and (v - dtime) or nil
		end
		modstore:set_string("squelch", squelch)
	end)

local is_door = {groups = {door = true}}

function nodecore.operate_door(pos, node, dir)
	local key = minetest.hash_node_position(pos)
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
			found[minetest.hash_node_position(p)] = {pos = p, node = n}
		end
	) then return end

	local press
	local toop = {}
	for k, v in pairs(found) do
		local ffd = nodecore.facedirs[v.node.param2 or 0]
		v.dir = ffd[rotdir]
		v.dir2 = rotdir == "r" and ffd.k or ffd.l
		local to = vector.add(v.pos, v.dir)

		if (not found[minetest.hash_node_position(to)])
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

		local str = minetest.hash_node_position(to)
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
			minetest.sound_play("nc_doors_operate",
				{pos = press.pos, gain = 0.5})
		end
		return true
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
				toset[minetest.hash_node_position(v.to)] = {
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
			local k = "sfx" .. minetest.hash_node_position(p)
			if not squelch[k] then
				squelch[k] = 0
				minetest.sound_play("nc_doors_operate",
					{pos = v.pos, gain = 0.5})
			end
		else
			nodecore.fallcheck({x = pos.x, y = pos.y + 1, z = pos.z})
		end
	end
	for _, v in pairs(found) do
		trypush({x = v.pos.x, y = v.pos.y + 1, z = v.pos.z}, v.dir, v.dir2)
	end
	for _, v in pairs(toop) do
		nodecore.operate_door(v.pos, nil, v.dir)
		trypush(v.pos, v.dir)
	end
	return true
end
