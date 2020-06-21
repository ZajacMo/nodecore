-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, string
    = ItemStack, minetest, nodecore, string
local string_format
    = string.format
-- LUALOCALS > ---------------------------------------------------------

local function shortdesc(stack, noqty)
	stack = ItemStack(stack)
	if noqty and stack:get_count() > 1 then stack:set_count(1) end
	local pre = stack:to_string()
	stack:get_meta():from_table({})
	local desc = stack:to_string()
	if pre == desc then return desc end
	return string_format("%s @%d", desc, #pre - #desc)
end
nodecore.stack_shortdesc = shortdesc

local function family(stack)
	if stack:is_empty() then return "" end
	local name = stack:get_name()
	local def = minetest.registered_items[name]
	return def and def.stackfamily or stack:to_string()
end
function nodecore.stack_merge(dest, src)
	if dest:is_empty() then return dest:add_item(src) end
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
	nodecore.visinv_update_ents(pos)
	return ...
end

function nodecore.stack_set(pos, stack, player)
	if player then
		nodecore.log("action", string_format("%s sets stack %q at %s",
				player:get_player_name(), shortdesc(stack), minetest.pos_to_string(pos)))
	end
	return update(pos, nodecore.node_inv(pos):set_stack("solo", 1, ItemStack(stack)))
end

function nodecore.stack_add(pos, stack, player)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def.stack_allow then
		local ret = def.stack_allow(pos, node, stack)
		if ret == false then return stack end
		if ret and ret ~= true then return ret end
	end
	stack = ItemStack(stack)
	local donate = stack:get_count()
	local item = nodecore.stack_get(pos)
	local exist = item:get_count()
	local left
	if item:is_empty() then
		left = nodecore.node_inv(pos):add_item("solo", stack)
	else
		left = nodecore.stack_merge(item, stack)
		nodecore.stack_set(pos, item)
	end
	local remain = left:get_count()
	if donate ~= remain then
		if player then
			nodecore.log("action", string_format(
					"%s adds stack %q %d + %d = %d + %d at %s",
					player:get_player_name(), shortdesc(stack, true),
					exist, donate, exist + donate - remain, remain,
					minetest.pos_to_string(pos)))
		end
		nodecore.stack_sounds(pos, "place")
	end
	return update(pos, left)
end

function nodecore.stack_giveto(pos, player)
	local stack = nodecore.stack_get(pos)
	local qty = stack:get_count()
	if qty < 1 then return true end

	local left = player:get_inventory():add_item("main", stack)
	local remain = left:get_count()
	if remain == qty then return stack:is_empty() end

	nodecore.log("action", string_format(
			"%s takes stack %q %d - %d = %d at %s",
			player:get_player_name(), shortdesc(stack, true),
			qty, qty - remain, remain, minetest.pos_to_string(pos)))

	nodecore.stack_sounds(pos, "dug")
	nodecore.stack_set(pos, left)
	return stack:is_empty()
end
