-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, pairs, setmetatable, type, vector
= ItemStack, math, minetest, pairs, setmetatable, type, vector
local math_floor, math_random, math_sqrt
= math.floor, math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function stackentprops(stack, func, rot)
	rot = rot or 1
	local t = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4 },
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false
	}
	if stack then
		t.is_visible = true
		t.textures[1] = stack:get_name()
		local s = 0.2 + 0.1 * stack:get_count() / stack:get_stack_max()      
		t.visual_size = {x = s, y = s}
		t.automatic_rotate = rot * 0.15 * math_sqrt(stack:get_stack_max()
			/ stack:get_count())
		if func then func(s) end
	end
	return t
end

minetest.register_entity(modname .. ":stackent", {
		initial_properties = stackentprops(),
		is_stack = true,
		itemcheck = function(self)
			local pos = self.object:getpos()
			local meta = minetest.get_meta(pos)
			if not meta then return self.object:remove() end
			local inv = meta:get_inventory()
			if not inv then return self.object:remove() end
			local stack = inv:get_stack("solo", 1)
			if not stack or stack:get_count() < 1 then return self.object:remove() end
			self.rot = self.rot or math_random(1, 2) * 2 - 3
			self.object:set_properties(stackentprops(stack, function(s)
						pos.y = math_floor(pos.y + 0.5) - 0.5 + s
						self.object:setpos(pos)
					end, self.rot))
		end,
		on_activate = function(self)
			self.cktime = 0.00001
		end,
		on_step = function(self, dtime)
			self.cktime = (self.cktime or 0) - dtime
			if self.cktime > 0 then return end
			self.cktime = 1
			return self:itemcheck()
		end
	})

local stackbox = {
	type = "fixed",
	fixed = {
		{-0.4, -0.5, -0.4, 0.4, 0.3, 0.4}
	},
}

local function findstackents(pos)
	local found = {}
	for k, v in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if v and v.get_luaentity and v:get_luaentity()
		and v:get_luaentity().is_stack then
			found[#found + 1] = v
		end
	end
	return found
end

minetest.register_node(modname .. ":stack", {
		drawtype = "airlike",
		tiles = { "crack_anylength.png" },
		walkable = true,
		selection_box = stackbox,
		collision_box = stackbox,
		drop = {},
		groups = {
			crumbly = 3,
			falling_node = 1,
			falling_repose = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size("solo", 1)
			if #(findstackents(pos)) < 1 then
				minetest.add_entity(pos, modname .. ":stackent")
			end
		end,
		after_destruct = function(pos)
			for k, v in pairs(findstackents(pos)) do
				v:remove()
			end
			minetest.after(0, function()
					minetest.check_for_falling(pos)
				end)
		end,
		on_dig = function(pos, node, digger)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local stack = inv:get_stack("solo", 1)
			if stack and not stack:is_empty() and digger then
				stack = digger:get_inventory()
				:add_item("main", stack)
				inv:set_stack("solo", 1, stack:to_string())
			end
			if not stack or stack:is_empty() then
				return minetest.remove_node(pos)
			end
		end,
		repose_drop = function(posfrom, posto, node)
			local meta = minetest.get_meta(posfrom)
			local inv = meta:get_inventory()
			local stack = inv:get_stack("solo", 1)
			if stack and not stack:is_empty() then
				minetest.item_drop(stack, nil, posto)
			end
			return minetest.remove_node(posfrom)
		end,
		on_punch = function() end
	})

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
		local stack = ItemStack(self.itemstring)
		local name = stack:get_name()
		if stack:get_count() == 1 and minetest.registered_nodes[name] then
			minetest.set_node(pos, {name = name})
		else
			minetest.set_node(pos, {name = modname .. ":stack"})
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_stack("solo", 1, self.itemstring)
		end
		self.itemstring = ""
		self.object:remove()
	end,
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
