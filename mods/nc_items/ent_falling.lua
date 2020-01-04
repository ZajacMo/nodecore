-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_falling_node_on_setnode(function(self, node, meta)
		if node and node.name == modname .. ":stack"
		and meta and meta.inventory and meta.inventory.solo then
			local stack = ItemStack(meta.inventory.solo[1] or "")
			if not stack:is_empty() then
				local ent = minetest.add_item(self.object:get_pos(), stack)
				if ent then ent:set_velocity(self.object:get_velocity()) end
				self.object:remove()
				return true
			end
		end
	end)
