-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, table, vector
    = ipairs, math, minetest, nodecore, pairs, table, vector
local math_abs, math_max, table_sort
    = math.abs, math.max, table.sort
-- LUALOCALS > ---------------------------------------------------------

-- To register a tool as a rake, provide a callback:
-- on_rake(pos, node, user) returns volume, checkfunc
-- volume: ordered array of relative positions to be dug by rake
-- checkfunc(pos, node, rel): determine if item can be dug
-- rel: relative vector taken from volume array
-- returns true to dig, nil to not dig, false to abort loop

local volcache = {}
function nodecore.rake_volume(dxmax, dymax, dzmax)
	dzmax = dzmax or dxmax
	local key = minetest.pos_to_string({x = dxmax, y = dymax, z = dzmax})
	local rakepos = volcache[key]
	if rakepos then return rakepos end
	rakepos = {}
	for dy = -dymax, dymax do
		for dx = -dxmax, dxmax do
			for dz = -dzmax, dzmax do
				local v = {x = dx, y = dy, z = dz}
				v.d = vector.length(v)
				v.rxz = math_max(math_abs(dx), math_abs(dz))
				v.ry = math_abs(dy)
				rakepos[#rakepos + 1] = v
			end
		end
	end
	table_sort(rakepos, function(a, b) return a.d < b.d end)
	volcache[key] = rakepos
	return rakepos
end

function nodecore.rake_index(filterfunc)
	local rakable = {}
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_nodes) do
				if filterfunc(v, k) then
					rakable[k] = true
				end
			end
		end)
	return function(_, node) return rakable[node.name] end
end

local function deferfall(func, ...)
	local oldfall = minetest.check_for_falling
	minetest.check_for_falling = nodecore.fallcheck
	local function helper(...)
		minetest.check_for_falling = oldfall
		return ...
	end
	return helper(func(...))
end

local laststack
local lastraking
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, node, user, ...)
	laststack = nodecore.stack_get(pos)
	local wield = nodecore.machine_digging and nodecore.machine_digging.tool
	or user and user:is_player() and user:get_wielded_item()
	lastraking = wield and (wield:get_definition() or {}).on_rake
	if lastraking then return deferfall(old_node_dig, pos, node, user, ...) end
	return old_node_dig(pos, node, user, ...)
end

local stackonly = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups.is_stack_only then stackonly[k] = true end
		end
	end)
local function matching(_, na, pb, nb)
	if stackonly[na.name] then
		if not stackonly[nb.name] then return end
		return (laststack and nodecore.stack_family(laststack))
		== nodecore.stack_family(nodecore.stack_get(pb))
	end
	return nodecore.stack_family(na.name) == nodecore.stack_family(nb.name)
end

local function dorake(volume, check, pos, node, user, ...)
	local sneak = user and user:get_player_control().sneak or nodecore.machine_digging
	local objpos = {}
	for _, rel in ipairs(volume) do
		local p = vector.add(pos, rel)
		if not (nodecore.machine_digging
			and vector.equals(nodecore.machine_digging.toolpos, p)) then
			local n = minetest.get_node(p)
			local allow = (rel.d > 0 or nil) and check(p, n, rel)
			if allow == false then break end
			if allow and ((not sneak) or matching(pos, node, p, n)) then
				minetest.node_dig(p, n, user, ...)
				objpos[minetest.hash_node_position(p)] = true
			end
		end
	end
	for _, lua in pairs(minetest.luaentities) do
		if lua.name == "__builtin:item" then
			local p = lua.object and lua.object:get_pos()
			if p and objpos[minetest.hash_node_position(
				vector.round(p))] then
				lua.object:set_pos(pos)
			end
		end
	end
end

local rakelock = {}

nodecore.register_on_dignode("rake handling", function(pos, node, user, ...)
		local nowraking = lastraking
		if not nowraking then return end
		lastraking = nil

		if not (pos and node) then return end
		local volume, check = nowraking(pos, node, user, ...)
		if not (volume and check) then return end

		local pname = user and user:is_player()
		and user:get_player_name() or nowraking
		if rakelock[pname] then return end
		rakelock[pname] = true
		deferfall(dorake, volume, check, pos, node, user, ...)
		rakelock[pname] = nil
	end)
