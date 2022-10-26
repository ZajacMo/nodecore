-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local stacks_only = nodecore.group_expand("group:is_stack_only", true)

nodecore.register_falling_node_on_setnode(function(self, node, meta)
		if not (node and stacks_only[node.name]) then return end
		local stack = nodecore.stack_get_serial(meta)
		if stack and not stack:is_empty() then
			local pos = self.object:get_pos()
			if not pos then return end
			local ent = minetest.add_item(pos, stack)
			if ent then ent:set_velocity(self.object:get_velocity()) end
			self.object:remove()
			return true
		end
	end)
