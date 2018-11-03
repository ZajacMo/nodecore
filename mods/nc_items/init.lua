-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, setmetatable, vector
    = ItemStack, minetest, nodecore, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local stackbox = nodecore.fixedbox(-0.4, -0.5, -0.4, 0.4, 0.3, 0.4)

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
