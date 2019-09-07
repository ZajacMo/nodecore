-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, setmetatable, vector
    = ItemStack, math, minetest, nodecore, setmetatable, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

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
		selection_box = nodecore.fixedbox(
			{-0.4, -0.5, -0.4, 0.4, 0.3, 0.4}
		),
		collision_box = nodecore.fixedbox(),
		drop = {},
		groups = {
			snappy = 1,
			falling_repose = 1,
			visinv = 1,
			is_stack_only = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		repose_drop = function(posfrom, posto)
			local stack = nodecore.stack_get(posfrom)
			if stack and not stack:is_empty() then
				nodecore.item_eject(posto, stack)
			end
			return minetest.remove_node(posfrom)
		end,
		on_rightclick = function(pos, node, whom, stack, pointed, ...)
			if not nodecore.interact(whom) then return stack end
			local def = nodecore.stack_get(pos):get_definition() or {}
			if def.stack_rightclick then
				local rtn = def.stack_rightclick(pos, node, whom, stack, pointed, ...)
				if rtn then return rtn end
			end
			return nodecore.stack_add(pos, stack)
		end,
		on_construct = function(pos, ...)
			minetest.after(0, function()
					return nodecore.stack_sounds(pos, "place")
				end)
			return nodecore.visinv_on_construct(pos, ...)
		end
	})

function nodecore.place_stack(pos, stack, placer, pointed_thing)
	stack = ItemStack(stack)

	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	if minetest.get_node(below).name == modname .. ":stack" then
		stack = nodecore.stack_add(below, stack)
		if stack:is_empty() then return end
	end

	minetest.set_node(pos, {name = modname .. ":stack"})
	nodecore.stack_set(pos, stack)
	if placer and pointed_thing then
		nodecore.craft_check(pos, {name = stack:get_name()}, {
				action = "place",
				crafter = placer,
				pointed = pointed_thing
			})
	end

	return minetest.after(0, function() minetest.check_for_falling(pos) end)
end

local bii = minetest.registered_entities["__builtin:item"]
local newbii = {
	on_step = function(self, dtime, ...)
		bii.on_step(self, dtime, ...)

		local pos = self.object:get_pos()
		if not self.oldpos or not vector.equals(pos, self.oldpos) then
			self.oldpos = pos
			self.sitting = 0
			return
		end
		self.sitting = (self.sitting or 0) + dtime
		if self.sitting < 0.25 then return end

		pos = vector.round(pos)
		local i = ItemStack(self.itemstring)
		pos = nodecore.scan_flood(pos, 5,
			function(p)
				if p.y > pos.y and math_random() < 0.95 then return end
				if p.y > pos.y + 1 then return end
				i = nodecore.stack_add(p, i)
				if i:is_empty() then return p end
				if nodecore.buildable_to(p) then return p end
			end)
		if not pos then return end
		if not i:is_empty() then nodecore.place_stack(pos, i) end
		self.itemstring = ""
		self.object:remove()
	end,
	on_punch = function(self, whom, ...)
		if not nodecore.interact(whom) then return end
		bii.on_punch(self, whom, ...)
		if self.itemstring ~= "" then
			local v = self.object:get_velocity()
			v.x = v.x + math_random() * 5 - 2.5
			v.y = v.y + math_random() * 5 - 2.5
			v.z = v.z + math_random() * 5 - 2.5
			self.object:set_velocity(v)
		end
	end
}
setmetatable(newbii, bii)
minetest.register_entity(":__builtin:item", newbii)

local bifn = minetest.registered_entities["__builtin:falling_node"]
local falling = {
	set_node = function(self, node, meta, ...)
		if node and node.name == modname .. ":stack"
		and meta and meta.inventory and meta.inventory.solo then
			local stack = ItemStack(meta.inventory.solo[1] or "")
			if not stack:is_empty() then
				local ent = minetest.add_item(self.object:get_pos(), stack)
				if ent then ent:set_velocity({x = 0, y = 0, z = 0}) end
				return self.object:remove()
			end
		end
		return bifn.set_node(self, node, meta, ...)
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)

function minetest.item_place(itemstack, placer, pointed_thing, param2)
	if not nodecore.interact(placer) then return end
	if pointed_thing.type == "node" and placer and
	not placer:get_player_control().sneak then
		local n = minetest.get_node(pointed_thing.under)
		local nn = n.name
		local nd = minetest.registered_items[nn]
		if nd and nd.on_rightclick then
			return nd.on_rightclick(pointed_thing.under, n,
				placer, itemstack, pointed_thing) or itemstack, false
		end
	end
	local def = itemstack:get_definition()
	if def.type == "node" and not def.place_as_item then
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

if nodecore.loaded_mods().nc_fire then
	nodecore.register_limited_abm({
			label = "Flammable ItemStacks Ignite",
			interval = 5,
			chance = 1,
			nodenames = {modname .. ":stack"},
			neighbors = {"group:igniter"},
			action = function(pos)
				local stack = nodecore.stack_get(pos)
				return nodecore.fire_check_ignite(pos, {name = stack:get_name()})
			end
		})
end

nodecore.register_cook_abm({nodenames = {modname .. ":stack"}})

if minetest.raycast then
	local olddrop = minetest.item_drop
	function minetest.item_drop(item, player, ...)
		local oldadd = minetest.add_item
		function minetest.add_item(pos, stack, ...)
			if not minetest.raycast then
				return oldadd(pos, stack, ...)
			end

			local start = player:get_pos()
			local eyeheight = player:get_properties().eye_height or 1.625
			start.y = start.y + eyeheight
			local target = vector.add(start, vector.multiply(player:get_look_dir(), 4))
			local pointed = minetest.raycast(start, target, false)()
			if (not pointed) or pointed.type ~= "node" then
				return oldadd(pos, stack, ...)
			end

			local dummyent = {}
			setmetatable(dummyent, {
					__index = function()
						return function() return {} end
					end
				})

			local name = stack:get_name()
			local function tryplace(p)
				if nodecore.match(p, {name = name, count = false}) then
					stack = nodecore.stack_add(p, stack)
					if stack:is_empty() then return dummyent end
				end
				if nodecore.buildable_to(p) then
					nodecore.place_stack(p, stack, player, pointed)
					return dummyent
				end
			end

			return tryplace(pointed.under)
			or tryplace(pointed.above)
			or oldadd(pos, stack, ...)
		end
		local function helper(...)
			minetest.add_item = oldadd
			return ...
		end
		return helper(olddrop(item, player, ...))
	end
end
