-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local raked = {}
local rakelock = {}

local wearrate = 65536 / 150

minetest.register_tool(modname .. ":rake", {
		description = "Rake",
		inventory_image = modname .. "_rake.png",
		tool_capabilities = nodecore.toolcaps({
				snappy = 1,
			}),
		sounds = nodecore.sounds("nc_tree_sticky"),
		after_use = function(stack, user, node, digparams)
			local def = node and node.name and minetest.registered_nodes[node.name]
			if not (def and def.groups and def.groups.snappy) then return end
			local pname = user and user:is_player() and user:get_player_name()
			if pname then raked[pname] = digparams end
			stack:add_wear(wearrate)
			if stack:get_count() < 1 then
				minetest.sound_play("nc_api_toolbreak",
					{object = user, gain = 0.5})
			end
			return stack
		end
	})

local function dorake(pname, pos, node, user, ...)
	local stack = user:get_wielded_item()
	if stack:get_name() ~= modname .. ":rake" then return end

	local digparams = raked[pname]
	if not digparams then return end

	for _, npos in pairs(minetest.find_nodes_in_area(
			{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
			{x = pos.x + 2, y = pos.y + 1, z = pos.z + 2},
			{node.name}
	)) do
		minetest.node_dig(npos, node, user, ...)
		for _, obj in pairs(minetest.get_objects_inside_radius(npos, 0.5)) do
			local lua = obj and obj.get_luaentity and obj:get_luaentity()
			if lua and lua.name == "__builtin:item" then
				obj:set_pos(pos)
			end
		end
	end
end

minetest.register_on_dignode(function(pos, node, user, ...)
		local def = minetest.registered_items[node.name]
		if not (def and def.groups and def.groups.falling_node) then return end

		local pname = user and user:is_player() and user:get_player_name()
		if not pname then return end

		if rakelock[pname] then return end
		rakelock[pname] = true
		dorake(pname, pos, node, user, ...)
		rakelock[pname] = nil

		raked[pname] = nil
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
