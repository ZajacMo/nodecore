-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, table, vector
    = ipairs, math, minetest, nodecore, pairs, table, vector
local math_abs, math_max, table_sort
    = math.abs, math.max, table.sort
-- LUALOCALS > ---------------------------------------------------------

-- To register a tool as a rake, provie a callback:
-- rake_check(itemname, rel, pos)
-- - itemname is name of the node being raked
-- - rel is a relative position vector plus d = distance from center
-- - pos is absolute position vector (no d)
-- return
-- - truthy to allow raking
-- - nil to disallow raking
-- - false to disallow and stop processing (max radius)

local dxzmax = 2
local dymax = 1
local rakepos = {}
for dy = -dymax, dymax do
	for dx = -dxzmax, dxzmax do
		for dz = -dxzmax, dxzmax do
			local v = {x = dx, y = dy, z = dz}
			v.d = vector.length(v)
			v.rxz = math_max(math_abs(dx), math_abs(dz))
			v.ry = math_abs(dy)
			rakepos[#rakepos + 1] = v
		end
	end
end
table_sort(rakepos, function(a, b) return a.d < b.d end)

local laststack
local lastraking
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, node, user, ...)
	laststack = nodecore.stack_get(pos)
	local wield = user and user:is_player() and user:get_wielded_item()
	lastraking = wield and (wield:get_definition() or {}).rake_check
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
		return (laststack and laststack:get_name()) == nodecore.stack_get(pb):get_name()
	end
	return na.name == nb.name
end

local function dorake(pos, node, user, ...)
	local sneak = user:get_player_control().sneak
	local objpos = {}
	for _, rel in ipairs(rakepos) do
		local p = vector.add(pos, rel)
		local n = minetest.get_node(p)
		local allow = (rel.d > 0 or nil) and lastraking(n.name, rel, p)
		if allow == false then break end
		if allow and ((not sneak) or matching(pos, node, p, n)) then
			minetest.node_dig(p, n, user, ...)
			objpos[minetest.hash_node_position(p)] = true
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
		if not lastraking then return end

		if not (pos and node and node.name
			and lastraking(node.name, rakepos[1], pos)) then return end
		if not user:is_player() then return end

		local pname = user:get_player_name()
		if rakelock[pname] then return end
		rakelock[pname] = true
		dorake(pos, node, user, ...)
		rakelock[pname] = nil

		lastraking = nil
	end)
