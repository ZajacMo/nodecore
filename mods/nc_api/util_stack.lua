-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore
    = ItemStack, ipairs, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local function family(stack)
	if stack:is_empty() then return "" end
	local name = stack:get_name()
	local def = minetest.registered_items[name]
	return def and def.stackfamily or stack:to_string()
end
function nodecore.stack_merge(dest, src)
	if dest:is_empty() then return dest:add_item(src) end
	local df = family(dest)
	local sf = family(src)
	if family(src) ~= family(dest) then
		return dest:add_item(src)
	end
	local o = src:get_name()
	src:set_name(dest:get_name())
	src = dest:add_item(src)
	if not src:is_empty() then
		src:set_name(o)
	end
	return src
end

function nodecore.node_inv(pos)
	return minetest.get_meta(pos):get_inventory()
end

function nodecore.stack_get(pos)
	return nodecore.node_inv(pos):get_stack("solo", 1)
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
	local item = nodecore.stack_get(pos)
	local left
	if item:is_empty() then
		left = nodecore.node_inv(pos):add_item("solo", stack)
	else
		left = nodecore.stack_merge(item, stack)
		nodecore.stack_set(pos, item)
	end
	if left:get_count() ~= stack:get_count() then
		nodecore.stack_sounds(pos, "place")
	end
	return update(pos, left)
end

function nodecore.stack_giveto(pos, player)
	local stack = nodecore.stack_get(pos)
	local qty = stack:get_count()
	if qty < 1 then return true end

	stack = player:get_inventory():add_item("main", stack)
	if stack:get_count() == qty then return stack:is_empty() end

	nodecore.stack_sounds(pos, "dug")
	nodecore.stack_set(pos, stack)
	return stack:is_empty()
end
