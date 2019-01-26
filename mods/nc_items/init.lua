-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, setmetatable, type,
vector
= ItemStack, ipairs, math, minetest, nodecore, setmetatable, type,
vector
local math_random
= math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local stackbox = nodecore.fixedbox(-0.4, -0.5, -0.4, 0.4, 0.3, 0.4)

local function invdef(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("solo", 1)
	if not stack or stack:is_empty() then return end
	local def = minetest.registered_items[stack:get_name()]
	return stack:get_count() == (def.pummel_stack or 1) and def or nil
end

minetest.register_node(modname .. ":stack", {
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(
			{-0.5, -0.5, -0.5, 0.5, -7/16, 0.5}
		),
		use_texture_alpha = true,
		tiles = {
			"nc_items_shadow.png",
			"nc_items_blank.png",
		},
		walkable = true,
		selection_box = stackbox,
		collision_box = stackbox,
		drop = {},
		groups = {
			flammable = 1,
			snappy = 1,
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
				nodecore.item_eject(posto, stack)
			end
			return minetest.remove_node(posfrom)
		end,
		pummeldefs = { 
			{
				check = function(pos, node, stats, ...)
					local def = invdef(pos)
					if not def or not def.pummeldefs then return end
					stats.def = def
					for i, v in ipairs(def.pummeldefs) do
						local ok = v.check(pos, node, stats, ...)
						if ok then return {v.resolve, ok} end
					end
				end,
				resolve = function(pos, node, stats, ...)
					local r = stats.check[1]
					stats.check = stats.check[2]
					return r(pos, node, stats, ...)
				end
			}
		}
	})

function nodecore.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)
	local name = stack:get_name()
	minetest.set_node(pos, {name = modname .. ":stack"})
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_stack("solo", 1, stack)
	if placer and pointed_thing then
		nodecore.craft_check(pos, {name = stack:get_name()}, placer, pointed_thing)
	end
	minetest.check_for_falling(pos)
end

local bii = minetest.registered_entities["__builtin:item"]
local item = {
	on_step = function(self, dtime)
		bii.on_step(self, dtime)
		if self.physical_state then return end
		local pos = vector.round(self.object:getpos())
		local i = ItemStack(self.itemstring)
		pos = nodecore.scan_flood(pos, 5,
			function(p)
				if p.y > pos.y then return end
				i = minetest.get_meta(p):get_inventory():add_item("solo", i)
				if i:is_empty() then return p end
				if nodecore.buildable_to(p) then return p end
			end)
		if not pos then return end
		if not i:is_empty() then nodecore.place_stack(pos, i) end
		self.itemstring = ""
		self.object:remove()
	end,
	on_punch = function(self)
		local v = self.object:get_velocity()
		v.x = v.x + math_random() * 5 - 2.5
		v.y = v.y + math_random() * 5 - 2.5
		v.z = v.z + math_random() * 5 - 2.5
		self.object:set_velocity(v)
	end
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
				nodecore.item_eject(self.object:getpos(), stack)
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
		local above = minetest.get_pointed_thing_position(pointed_thing, true)
		if above and nodecore.buildable_to(above) then
			nodecore.place_stack(above, itemstack:take_item(), placer, pointed_thing)
		end
	end
	return itemstack
end
