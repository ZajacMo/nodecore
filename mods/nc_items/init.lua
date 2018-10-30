local modname = minetest.get_current_modname()

local function stackentprops(stack)
	return {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4 },
		textures = {stack and stack:get_name() or ""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = not not stack
	}
end

minetest.register_entity(modname .. ":stackent", {
		initial_properties = stackentprops(),
		itemcheck = function(self)
			local pos = self.object:getpos()
			local meta = minetest.get_meta(pos)
			if not meta then return self.object:remove() end
			local inv = meta:get_inventory()
			if not inv then return self.object:remove() end
			local stack = inv:get_stack("main", 1)
			if not stack or stack:get_count() < 1 then return self.object:remove() end
			self.object:set_properties(stackentprops(stack))
		end,
		on_activate = function(self)
			return self:itemcheck()
		end,
		on_step = function(self, dtime)
			self.cktime = (self.cktime or 0) + dtime
			if self.cktime < 1 then return end
			self.cktime = 0
			return self:itemcheck()
		end,
	})

minetest.register_node(modname .. ":stack", {
		drawtype = "airlike",
		tiles = { "crack_anylength.png" },
		walkable = true,
		groups = {
			scoopy = 3,
			falling_node = 1
		},
		paramtype = "light",
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size("main", 1)
		end,
		on_dig = function(pos, ...)
			local def = minetest.registered_nodes[modname .. ":stack"]
			local old = def.drop
			local function helper(...)
				rawset(def, "drop", old)
				return ...
			end
			rawset(def, "drop", minetest.get_meta(pos):get_inventory()
				:get_stack("main", 1):to_string())
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
			inv:set_stack("main", 1, self.itemstring)
			minetest.add_entity(pos, modname .. ":stackent")
		end
		self.itemstring = ""
		self.object:remove()
	end,
}
setmetatable(item, bii)
minetest.register_entity(":__builtin:item", item)