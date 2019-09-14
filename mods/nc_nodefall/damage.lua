-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs
    = ItemStack, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local function register(fallname, mult, getname)
	local fallnode = minetest.registered_entities[fallname]

	local oldtick = fallnode.on_step
	fallnode.on_step = function(self, dtime, ...)
		if not self.crush_damage then
			local def = minetest.registered_items[getname(self)]
			self.crush_damage = def and def.crush_damage or 0
		end
		if self.crush_damage <= 0 then
			return oldtick(self, dtime, ...)
		end

		local pos = self.object:get_pos()
		pos.y = pos.y - 1
		local v = -self.object:get_velocity().y
		if v <= 0 then
			return oldtick(self, dtime, ...)
		end
		local q = v * v * dtime * self.crush_damage * mult
		for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if o:is_player() then
				nodecore.addphealth(o, -q)
			end
		end

		return oldtick(self, dtime, ...)
	end

	minetest.register_entity(":" .. fallname, fallnode)
end

register("__builtin:falling_node", 1, function(s) return s.node.name end)
register("__builtin:item", 0.2, function(s) return ItemStack(s.itemstring):get_name() end)
