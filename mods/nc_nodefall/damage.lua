-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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

	local pos = self.object:getpos()
	local vel = self.object:getvelocity()
	local v = vector.length(vel)
	local q = v * v * dtime * self.crush_damage
	for k, v in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		if v:is_player() then
			nodecore.addphealth(v, -q)
		end
	end

	return oldtick(self, dtime, ...)
end

minetest.register_entity(":" .. fallname, fallnode)
