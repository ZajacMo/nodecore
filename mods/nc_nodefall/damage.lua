-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local fallname = "__builtin:falling_node"
local fallnode = minetest.registered_entities[fallname]

local oldtick = fallnode.on_step
fallnode.on_step = function(self, dtime, ...)
	if not self.crush_damage then
		local def = minetest.registered_items[self.node.name]
		self.crush_damage = def and def.crush_damage or 0
	end
	if self.crush_damage <= 0 then
		return oldtick(self, dtime, ...)
	end

	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local v = vector.length(vel)
	local q = v * v * dtime * self.crush_damage
	for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		if o:is_player() then
			nodecore.addphealth(o, -q)
		end
	end

	return oldtick(self, dtime, ...)
end

minetest.register_entity(":" .. fallname, fallnode)
