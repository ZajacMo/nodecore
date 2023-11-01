-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, vector
    = ipairs, math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local operate_squelch = nodecore.setting_float(modname .. "_operate_squelch", 0.5,
	"Door operation squelch time", [[WARNING: FUNDAMENTAL CONSTANT. Time after
	a door has been operated that further operations are "squelched"
	(ignored/blocked). Changing this may fundamentally alter the game,
	including making your builds incompatible across hosts.]])

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

local squelch = {}
nodecore.register_globalstep("door squelch", function(dtime)
		for k, v in pairs(squelch) do
			squelch[k] = (v > dtime) and (v - dtime) or nil
		end
	end)

local is_door = {groups = {door = true}}

local door_operate_queue = {}
local operate_success = {}

local function door_operate_sound(pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local vol = def and def.groups and def.groups.door_operate_sound_volume

	local gain = 0.5
	if vol and vol > 0 then gain = gain * vol / 100 end
	nodecore.sound_play("nc_doors_operate",
		{pos = pos, gain = gain})
end

local function facedir(node)
	local p2 = node.param2 or 0
	local def = minetest.registered_nodes[node.name]
	local data = def and def.spindata
	p2 = data and data.equiv[p2] or p2
	return nodecore.facedirs[p2]
end

local function operate_door_core(pos, node, dir)
	local key = hashpos(pos)
	operate_success[key] = nil
	if squelch[key] then return end

	node = node or minetest.get_node_or_nil(pos)
	if (not node) or (not nodecore.match(node, is_door)) then return end

	local fd = facedir(node)
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
		local ffd = facedir(v.node)
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
			dir2 = rotdir == "r" and ffd.r or ffd.l,
			from = v
		}
		toop[k .. "k"] = {
			pos = vector.add(v.pos, ffd.k),
			dir = rotdir == "r" and ffd.r or ffd.l,
			dir2 = rotdir == "r" and ffd.k or ffd.f,
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
			door_operate_sound(press.pos)
			operate_success[key] = true
			return
		end
		return
	end

	local toset = {}
	for k, v in pairs(found) do
		toset[k] = {pos = v.pos, name = "air", param2 = 0}
		squelch[k] = operate_squelch
		squelch[v.str] = operate_squelch
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
		nodecore.set_node_check(v.pos, v)
		if v.name ~= "air" then
			local p = vector.round(vector.multiply(v.pos, 0.25))
			local k = "sfx" .. hashpos(p)
			if not squelch[k] then
				squelch[k] = 0
				door_operate_sound(v.pos)
			end
		else
			nodecore.fallcheck({x = pos.x, y = pos.y + 1, z = pos.z})
		end
	end
	for _, v in pairs(found) do
		nodecore.door_push({x = v.pos.x, y = v.pos.y + 1, z = v.pos.z}, v.dir2, v.dir)
	end
	for _, v in pairs(toop) do
		door_operate_queue[#door_operate_queue + 1] = {v.pos, nil, v.dir}
		nodecore.door_push(v.pos, {
				x = v.dir.x,
				y = v.dir.y,
				z = v.dir.z,
				after = v.dir.y ~= 0 and v.dir2 or nil
			})
	end
	operate_success[key] = true
end

local running
function nodecore.operate_door(pos, node, dir)
	door_operate_queue[#door_operate_queue + 1] = {pos, node, dir}
	local key = hashpos(pos)
	if running then return operate_success[key] end
	running = true
	while #door_operate_queue > 0 do
		local batch = door_operate_queue
		door_operate_queue = {}
		for i = #batch, 2, -1 do
			local j = math_random(1, i)
			batch[i], batch[j] = batch[j], batch[i]
		end
		for _, opts in ipairs(batch) do
			operate_door_core(opts[1], opts[2], opts[3])
		end
	end
	running = false
	return operate_success[key]
end
