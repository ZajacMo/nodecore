-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, setmetatable
    = ItemStack, minetest, setmetatable
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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
