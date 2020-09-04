-- LUALOCALS < ---------------------------------------------------------
local ItemStack, getmetatable, math, minetest, nodecore, pairs, string,
      vector
    = ItemStack, getmetatable, math, minetest, nodecore, pairs, string,
      vector
local math_cos, math_floor, math_pi, math_random, math_sin,
      string_format
    = math.cos, math.floor, math.pi, math.random, math.sin,
      string.format
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
	stack = ItemStack(stack)
	if stack:is_empty() then return "" end
	local name = stack:get_name()
	local def = minetest.registered_items[name]
	if def and def.stackfamily then
		stack:set_name(def.stackfamily)
	end
	if stack:get_count() > 1 then
		stack:set_count(1)
	end
	return stack:to_string()
end
nodecore.stack_family = family
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

function nodecore.item_eject(pos, stack, speed, qty, vel)
	stack = ItemStack(stack)
	speed = speed or 0
	vel = vel or {x = 0, y = 0, z = 0}
	if speed == 0 and vel.x == 0 and vel.y == 0 and vel.z == 0
	and nodecore.place_stack and minetest.get_node(pos).name == "air" then
		stack:set_count(stack:get_count() * (qty or 1))
		return nodecore.place_stack(pos, stack)
	end
	for _ = 1, (qty or 1) do
		local v = {x = vel.x, y = vel.y, z = vel.z}
		if speed > 0 then
			local inc = math_random() * math_pi / 3
			local y = math_sin(inc)
			local xz = math_cos(inc)
			local theta = math_random() * math_pi * 2
			local x = math_sin(theta) * xz
			local z = math_cos(theta) * xz
			v = {
				x = v.x + x * speed,
				y = v.y + y * speed,
				z = v.z + z * speed
			}
		end
		local p = {x = pos.x, y = pos.y + 0.25, z = pos.z}
		local obj = minetest.add_item(p, stack)
		if obj then obj:set_velocity(v) end
	end
end

do
	local stddirs = {}
	for _, v in pairs(nodecore.dirs()) do
		if v.y <= 0 then stddirs[#stddirs + 1] = v end
	end
	function nodecore.item_disperse(pos, name, qty, outdirs)
		if qty < 1 then return end
		local dirs = {}
		for _, d in pairs(outdirs or stddirs) do
			local p = vector.add(pos, d)
			if nodecore.buildable_to(p) then
				dirs[#dirs + 1] = {pos = p, qty = 0}
			end
		end
		if #dirs < 1 then
			return nodecore.item_eject(pos, name .. " " .. qty)
		end
		for _ = 1, qty do
			local p = dirs[math_random(1, #dirs)]
			p.qty = p.qty + 1
		end
		for _, v in pairs(dirs) do
			if v.qty > 0 then
				nodecore.item_eject(v.pos, name .. " " .. v.qty)
			end
		end
	end
end

local function item_lose(player, listname, slot, speed)
	local inv = player:get_inventory()
	local stack = inv:get_stack(listname, slot)
	if stack:is_empty() or nodecore.item_is_virtual(stack) then return end

	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height

	local def = stack:get_definition() or {}
	if def.on_drop
	and def.on_drop ~= minetest.item_drop
	and def.on_drop ~= minetest.nodedef_default.on_drop
	and def.on_drop ~= minetest.craftitemdef_default.on_drop
	and def.on_drop ~= minetest.tooldef_default.on_drop
	and def.on_drop ~= minetest.noneitemdef_default.on_drop then
		nodecore.log("action", string_format("%s loses item %q at %s by on_drop",
				player:get_player_name(), shortdesc(stack),
				minetest.pos_to_string(pos, 0)))
		stack = def.on_drop(stack, player, pos)
		return inv:set_stack(listname, slot, stack)
	end

	nodecore.log("action", string_format("%s loses item %q at %s by eject(%d)",
			player:get_player_name(), shortdesc(stack),
			minetest.pos_to_string(pos, 0), math_floor(speed + 0.5)))
	nodecore.item_eject(pos, stack, speed)
	return inv:set_stack(listname, slot, "")
end
nodecore.item_lose = item_lose

function nodecore.inventory_dump(player)
	for listname, list in pairs(player:get_inventory():get_lists()) do
		if listname ~= "hand" then
			for slot in pairs(list) do
				item_lose(player, listname, slot, 0.001)
			end
		end
	end
end

local keeppriv = "keepinv"
minetest.register_privilege(keeppriv, {
		description = "Allow player to keep inventory on teleport",
		give_to_singleplayer = false,
		give_to_admin = false
	})

local telefunc = minetest.registered_chatcommands.teleport
telefunc = telefunc and telefunc.func
if telefunc then
	minetest.registered_chatcommands.teleport.func = function(...)
		local anyplayer = minetest.get_connected_players()[1]
		local meta = anyplayer and getmetatable(anyplayer)
		local oldsetpos = meta and meta.set_pos
		if not oldsetpos then return telefunc(...) end
		meta.set_pos = function(player, ...)
			if not minetest.check_player_privs(player, keeppriv) then
				nodecore.inventory_dump(player)
			end
			return oldsetpos(player, ...)
		end
		local function helper(...)
			meta.set_pos = oldsetpos
			return ...
		end
		return helper(telefunc(...))
	end
end
