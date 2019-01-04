-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, setmetatable, vector
= ItemStack, minetest, nodecore, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local stackbox = nodecore.fixedbox(-0.4, -0.5, -0.4, 0.4, 0.3, 0.4)

local function invdef(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("solo", 1)
	if not stack or stack:is_empty() then return end
	return minetest.registered_items[stack:get_name()]
end

minetest.register_node(modname .. ":stack", {
		drawtype = "airlike",
		tiles = { "nc_items_matte.png" },
		walkable = true,
		selection_box = stackbox,
		collision_box = stackbox,
		drop = {},
		groups = {
			crumbly = 3,
			falling_node = 1,
			falling_repose = 1,
			visinv = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		repose_drop = function(posfrom, posto, node)
			local meta = minetest.get_meta(posfrom)
			local inv = meta:get_inventory()
			local stack = inv:get_stack("solo", 1)
			if stack and not stack:is_empty() then
				minetest.item_drop(stack, nil, posto)
			end
			return minetest.remove_node(posfrom)
		end,
		can_pummel = function(pos, ...)
			local def = invdef(pos)
			return def and def.can_pummel and def.can_pummel(pos, ...)
		end,
		on_pummel = function(pos, ...)
			local def = invdef(pos)
			return def and def.on_pummel and def.on_pummel(pos, ...)
		end
	})

function nodecore.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)
	local name = stack:get_name()
	if stack:get_count() == 1 and stack:get_definition().type == "node" then
		minetest.set_node(pos, {name = name})
	else
		minetest.set_node(pos, {name = modname .. ":stack"})
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_stack("solo", 1, stack)
	end
	if placer and pointed_thing then
		nodecore.craft_check(pos, {name = stack:get_name()}, placer, pointed_thing)
	end
	minetest.check_for_falling(pos)
end

local function buildable_to(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name].buildable_to and pos
end
local bii = minetest.registered_entities["__builtin:item"]
local item = {
	on_step = function(self, dtime)
		bii.on_step(self, dtime)
		if self.physical_state then return end
		local pos = vector.round(self.object:getpos())
		pos = buildable_to(pos)
		or buildable_to({x = pos.x + 1, y = pos.y, z = pos.z})
		or buildable_to({x = pos.x - 1, y = pos.y, z = pos.z})
		or buildable_to({x = pos.x, y = pos.y, z = pos.z + 1})
		or buildable_to({x = pos.x, y = pos.y, z = pos.z - 1})
		if not pos then return end
		nodecore.place_stack(pos, self.itemstring)
		self.itemstring = ""
		self.object:remove()
	end,
	on_punch = function() end
}
setmetatable(item, bii)
minetest.register_entity(":__builtin:item", item)

local bifn = minetest.registered_entities["__builtin:falling_node"]
local falling = {
	set_node = function(self, node, meta, ...)
		if node and node.name == modname .. ":stack"
		and meta and meta.inventory and meta.inventory.solo then
			local stack = ItemStack(meta.inventory.solo[1] or "")
			if not stack:is_empty() then
				minetest.item_drop(stack, nil, self.object:getpos())
				return self.object:remove()
			end
		end
		return bifn.set_node(self, node, meta, ...)
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)

function minetest.item_place(itemstack, placer, pointed_thing, param2)
	if pointed_thing.type == "node" and placer and
	not placer:get_player_control().sneak then
		local n = minetest.get_node(pointed_thing.under)
		local nn = n.name
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
			return minetest.registered_nodes[nn].on_rightclick(pointed_thing.under, n,
				placer, itemstack, pointed_thing) or itemstack, false
		end
	end
	if itemstack:get_definition().type == "node" then
		return minetest.item_place_node(itemstack, placer, pointed_thing, param2)
	end
	if not itemstack:is_empty() then
		nodecore.place_stack(minetest.get_pointed_thing_position(pointed_thing, true),
			itemstack:take_item(), placer, pointed_thing)
	end
	return itemstack
end
