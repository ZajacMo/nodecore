-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, pairs, table, vector
    = ipairs, minetest, nodecore, pairs, table, vector
local table_sort
    = table.sort
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_tool(modname .. ":rake", {
		description = "Rake",
		inventory_image = modname .. "_rake.png",
		tool_capabilities = nodecore.toolcaps({
				snappy = 1,
				uses = 10
			}),
		groups = {flammable = 1},
		sounds = nodecore.sounds("nc_tree_sticky")
	})

local rakable = {}
local stackonly = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.falling_node and v.groups.snappy == 1 then
				rakable[k] = true
				if v.groups.is_stack_only then stackonly[k] = true end
			end
		end
	end)

local rakepos = {}
for dy = -1, 1 do
	for dx = -2, 2 do
		for dz = -2, 2 do
			rakepos[#rakepos + 1] = {x = dx, y = dy, z = dz}
		end
	end
end
table_sort(rakepos, function(a, b) return vector.length(a) < vector.length(b) end)

local laststack
local lastraking
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, node, user, ...)
	laststack = nodecore.stack_get(pos)
	local wield = user and user:is_player() and user:get_wielded_item()
	lastraking = wield and wield:get_name() == modname .. ":rake"
	return old_node_dig(pos, node, user, ...)
end

local function matching(_, na, pb, nb)
	if stackonly[na.name] then
		if not stackonly[nb.name] then return end
		return (laststack and laststack:get_name()) == nodecore.stack_get(pb):get_name()
	end
	return na.name == nb.name
end

local function dorake(pos, node, user, ...)
	local sneak = user:get_player_control().sneak
	for _, rel in ipairs(rakepos) do
		local p = vector.add(pos, rel)
		local n = minetest.get_node(p)
		if rakable[n.name] and ((not sneak) or matching(pos, node, p, n)) then
			minetest.node_dig(p, n, user, ...)
		end
		for _, obj in pairs(nodecore.get_objects_at_pos(p)) do
			local lua = obj and obj.get_luaentity and obj:get_luaentity()
			if lua and lua.name == "__builtin:item" then
				obj:set_pos(pos)
			end
		end
	end
end

local rakelock = {}

nodecore.register_on_dignode("rake handling", function(pos, node, user, ...)
		if not lastraking then return end

		if not (node and node.name and rakable[node.name]) then return end
		if not user:is_player() then return end

		local pname = user:get_player_name()
		if rakelock[pname] then return end
		rakelock[pname] = true
		dorake(pos, node, user, ...)
		rakelock[pname] = nil

		lastraking = nil
	end)

local adze = {name = modname .. ":adze", wear = 0.05}
nodecore.register_craft({
		label = "assemble rake",
		norotate = true,
		nodes = {
			{match = "nc_tree:stick", replace = "air"},
			{x = 0, z = -1, match = adze, replace = "air"},
			{x = 0, z = 1, match = adze, replace = "air"},
			{x = -1, z = 0, match = adze, replace = "air"},
			{x = 1, z = 0, match = adze, replace = "air"},
		},
		items = {
			modname .. ":rake"
		}
	})
