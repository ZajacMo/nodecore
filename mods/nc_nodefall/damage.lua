-- LUALOCALS < ---------------------------------------------------------
local math, minetest, pairs, vector
    = math, minetest, pairs, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local fallname = "__builtin:falling_node"
local fallnode = minetest.registered_entities[fallname]

local dmg = {}

local function dmggc()
	dmg = {}
	minetest.after(10, dmggc)
end
dmggc()

local oldtick = fallnode.on_step
fallnode.on_step = function(self, dtime, ...)
	local pos = self.object:getpos()
	local vel = self.object:getvelocity()

	local q = dmg[self] or 0
	local v = vector.length(vel)
	q = q + v * v * dtime
	minetest.log(q)
	if q > 1 then
		local n = math_floor(q)
		for k, v in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			v:set_hp(v:get_hp() - n)
		end
		q = q - n
	end
	dmg[self] = q

	return oldtick(self, dtime, ...)
end

minetest.register_entity(":" .. fallname, fallnode)
