local minetest = minetest
local modname = minetest.get_current_modname()

local function stackentprops(stack, func)
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
		is_visible = false,
		automatic_rotate = math.pi * 0.05,
	}
	if stack then
		t.is_visible = true
		t.textures[1] = stack:get_name()
		local s = stack:get_count() / stack:get_stack_max() * 0.35 + 0.05
		t.visual_size = {x = s, y = s}
		if func then func(s) end
	end
	return t
end

minetest.register_entity(modname .. ":stackent", {
		initial_properties = stackentprops(),
		is_stack = true,
		die = function(self)
			return self.object:remove()
		end,
		itemcheck = function(self)
			local pos = self.object:getpos()
			local meta = minetest.get_meta(pos)
			if not meta then return self:die() end
			local inv = meta:get_inventory()
			if not inv then return self:die() end
			local stack = inv:get_stack("solo", 1)
			if not stack or stack:get_count() < 1 then return self:die() end
			self.object:set_properties(stackentprops(stack, function(s)
						pos.y = math.floor(pos.y + 0.5) - 0.5 + s
						self.object:setpos(pos)
					end))
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
		if v.get_luaentity and v:get_luaentity().is_stack then
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
		groups = {
			scoopy = 3,
			falling_node = 1
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
		on_destruct = function(pos)
			for k, v in pairs(findstackents(pos)) do
				v:remove()
			end
		end,
		on_dig = function(pos, ...)
			local def = minetest.registered_nodes[modname .. ":stack"]
			local old = def.drop
			local function helper(...)
				rawset(def, "drop", old)
				return ...
			end
			rawset(def, "drop", minetest.get_meta(pos):get_inventory()
				:get_stack("solo", 1):to_string())
			print(minetest.serialize(def.drop))
			return helper(minetest.node_dig(pos, ...))
		end
	})

local bii = minetest.registered_entities["__builtin:item"]
local item = {
	on_step = function(self, dtime)
		bii.on_step(self, dtime)
		if self.physical_state then return end
		local pos = self.object:getpos()
		pos.x = math.floor(pos.x + 0.5)
		pos.y = math.floor(pos.y + 0.5)
		pos.z = math.floor(pos.z + 0.5)
		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		if not def.buildable_to then return end
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