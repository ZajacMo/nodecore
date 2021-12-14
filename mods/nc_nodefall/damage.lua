-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs
    = ItemStack, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local function getcrushdamage(name, alreadyloose)
	local def = minetest.registered_items[name]
	if def and def.crush_damage then return def.crush_damage end
	if alreadyloose then return 0 end
	return name and getcrushdamage(name .. "_loose", true) or 0
end

local function maketick(mult, getname, oldtick)
	oldtick = oldtick or function() end
	return function(self, dtime, ...)
		local age = self.crush_age or 0
		age = age + dtime
		self.crush_age = age
		if age < 1 then return end

		self.crush_damage = self.crush_damage or getcrushdamage(getname(self))
		if self.crush_damage <= 0 then
			return oldtick(self, dtime, ...)
		end

		local pos = self.object:get_pos()
		if not pos then return end
		pos.y = pos.y - 1
		local vel = self.object:get_velocity()
		local v = vel and -vel.y or 0
		if v <= 0 then
			return oldtick(self, dtime, ...)
		end
		local q = v * v * dtime * self.crush_damage * mult
		for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if o:is_player() then
				nodecore.addphealth(o, -q, {
						nc_type = "crushing",
						entity = self
					})
			end
		end

		return oldtick(self, dtime, ...)
	end
end

nodecore.register_falling_node_step(maketick(1, function(s) return s.node.name end))
nodecore.register_item_entity_step(maketick(0.2, function(s) return ItemStack(s.itemstring):get_name() end))
