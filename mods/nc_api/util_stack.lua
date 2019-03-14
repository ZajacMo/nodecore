-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore, pairs, unpack
    = ItemStack, ipairs, minetest, nodecore, pairs, unpack
-- LUALOCALS > ---------------------------------------------------------

function nodecore.node_inv(pos)
	return minetest.get_meta(pos):get_inventory()
end

function nodecore.stack_get(pos)
	return nodecore.node_inv(pos):get_stack("solo", 1)
end

function nodecore.stack_sounds(pos, kind, stack)
	stack = stack or nodecore.stack_get(pos)
	stack = ItemStack(stack)
	if stack:is_empty() then return end
	local def = minetest.registered_items[stack:get_name()] or {}
	if (not def.sounds) or (not def.sounds[kind]) then return end
	local t = {}
	for k, v in pairs(def.sounds[kind]) do t[k] = v end
	t.pos = pos
	return minetest.sound_play(t.name, t)
end
function nodecore.stack_sounds_delay(...)
	local t = {...}
	minetest.after(0, function()
			nodecore.stack_sounds(unpack(t))
		end)
end

local function update(pos, ...)
	for _, v in ipairs(nodecore.visinv_update_ents(pos)) do
		v:get_luaentity():itemcheck()
	end
	return ...
end

function nodecore.stack_set(pos, stack)
	return update(pos, nodecore.node_inv(pos):set_stack("solo", 1, ItemStack(stack)))
end

function nodecore.stack_add(pos, stack)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def.stack_allow then
		local ret = def.stack_allow(pos, node, stack)
		if ret == false then return stack end
		if ret and ret ~= true then return ret end
	end
	stack = ItemStack(stack)
	local left = nodecore.node_inv(pos):add_item("solo", stack)
	if left:get_count() ~= stack:get_count() then
		nodecore.stack_sounds(pos, "place")
	end
	return update(pos, left)
end

function nodecore.stack_giveto(pos, player)
	local stack = nodecore.stack_get(pos)
	local nstack = player:get_inventory():add_item("main", stack)
	if stack:get_count() == nstack:get_count() then return nstack:is_empty()end
	nodecore.stack_sounds(pos, "dug")
	nodecore.stack_set(pos, nstack)
	return nstack:is_empty()
end
