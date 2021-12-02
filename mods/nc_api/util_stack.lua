-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, string, vector
    = ItemStack, math, minetest, nodecore, pairs, string, vector
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

local metakey = "ncitem"

function nodecore.stack_get(pos, meta)
	meta = meta or minetest.get_meta(pos)
	local str = meta:get_string(metakey)
	if str and str ~= "" then return ItemStack(str) end
	local inv = meta:get_inventory()
	local stack = inv:get_stack("solo", 1)
	if stack:is_empty() then return stack end
	meta:set_string(metakey, stack:to_string())
	inv:set_size("solo", 0)
	return stack
end

function nodecore.stack_get_serial(metatable)
	local str = metatable
	str = str and str.fields
	str = str and str[metakey]
	if str and str ~= "" then return ItemStack(str) end
	local inv = metatable.inventory
	inv = inv and inv.solo
	inv = inv and inv[1]
	if inv and inv ~= "" then return ItemStack(inv) end
end

local function update(pos, ...)
	nodecore.visinv_update_ents(pos)
	return ...
end

function nodecore.stack_set(pos, stack, player, node, def)
	if player then
		nodecore.log("action", string_format("%s sets stack %q at %s",
				player:get_player_name(), shortdesc(stack), minetest.pos_to_string(pos)))
	end
	node = node or minetest.get_node(pos)
	def = def or minetest.registered_items[node.name] or {}
	local meta = minetest.get_meta(pos)
	stack = ItemStack(stack)
	local old = nodecore.stack_get(pos, meta)
	local stackstring = stack:to_string()
	meta:set_string(metakey, stackstring)
	if old:to_string() ~= stackstring then
		if def.on_stack_change then
			def.on_stack_change(pos, node, stack, old)
		end
		nodecore.fallcheck({x = pos.x, y = pos.y + 1, z = pos.z})
	end
	return update(pos)
end

function nodecore.stack_add(pos, stack, player, node, def)
	node = node or minetest.get_node(pos)
	def = def or minetest.registered_items[node.name] or {}
	if not def.can_have_itemstack then return stack end
	if def.stack_allow then
		local ret = def.stack_allow(pos, node, stack)
		if ret == false then return stack end
		if ret and ret ~= true then return ret end
	end
	stack = ItemStack(stack)
	local donate = stack:get_count()
	local item = nodecore.stack_get(pos)
	local exist = item:get_count()
	local left = nodecore.stack_merge(item, stack)
	nodecore.stack_set(pos, item, nil, node, def)
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

function nodecore.stack_giveto(pos, player, node, def)
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
	nodecore.stack_set(pos, left, nil, node, def)
	return stack:is_empty()
end

function nodecore.stack_settle(pos, stack, node, def, inside)
	stack = ItemStack(stack)
	if stack:is_empty() then return stack end
	node = node or minetest.get_node(pos)
	def = def or minetest.registered_items[node.name] or {}
	if not def.on_settle_item then return stack end
	return def.on_settle_item(pos, node, stack, inside)
end

function nodecore.stack_can_fall_in(pos, stack, node, def, ent)
	stack = ItemStack(stack)
	node = node or minetest.get_node(pos)
	def = def or minetest.registered_items[node.name] or {}
	if not def.can_item_fall_in then return def.buildable_to end
	return def.can_item_fall_in(pos, node, stack, ent)
end

local ejectdir
do
	local margin = 0.001
	local function theta2dir(theta)
		return {
			min = theta / 4 + margin,
			range = 1/2 - margin * 2
		}
	end
	local function checkdir(opts, pos, dx, dz, theta)
		local p = {x = pos.x + dx, y = pos.y, z = pos.z + dz}
		if nodecore.walkable(p) then return end
		opts[#opts + 1] = theta2dir(theta)
	end
	local anydir = {}
	for i = -1, 5, 2 do anydir[#anydir + 1] = theta2dir(i) end
	local function rawdirs(pos)
		local opts = {}
		checkdir(opts, pos, 1, 0, -1)
		checkdir(opts, pos, 0, 1, 1)
		checkdir(opts, pos, -1, 0, 3)
		checkdir(opts, pos, 0, -1, 5)
		if #opts < 1 then opts = anydir end
		return opts
	end

	local cache = {}
	function ejectdir(pos)
		local key = minetest.hash_node_position(vector.round(pos))
		local cached = cache[key] or math_random(1, 4)
		cache[key] = cached + 1
		local dirs = rawdirs(pos)
		return dirs[(cached % #dirs) + 1]
	end
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
			local dir = ejectdir(pos)
			local theta = dir.min + math_random() * dir.range
			theta = theta * math_pi
			local x = math_cos(theta) * xz
			local z = math_sin(theta) * xz
			v = {
				x = v.x + x * speed,
				y = v.y + y * speed,
				z = v.z + z * speed
			}
		end
		local p = {x = pos.x, y = pos.y + 0.25, z = pos.z}
		local obj = nodecore.add_item_raw(p, stack)
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
