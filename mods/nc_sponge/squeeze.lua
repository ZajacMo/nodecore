-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_entity(modname .. ":waterguard", {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		textures = {""},
		is_visible = false,
		static_save = true
	},
	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)
		if node.name ~= "nc_terrain:water_source" then
			return self.object:remove()
		end
		if not minetest.find_node_near(pos, 1, {modname .. ":sponge"}) then
			return minetest.remove_node(pos)
		end
	end
})

local spongedirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1}
}

nodecore.register_craft({
	label = "squeeze sponge",
	action = "pummel",
	toolgroups = {thumpy = 1},
	nodes = {
		{
			match = modname .. ":sponge_wet",
			replace = modname .. ":sponge"
		},
		{
			x = 1,
			match = "air"
		}
	},
	after = function(pos)
		local dirs = {}
		for _, d in pairs(spongedirs) do
			local p = vector.add(pos, d)
			if minetest.get_node(p).name == "air" then
				dirs[#dirs + 1] = p
			end
		end
		local p = dirs[math_random(1, #dirs)]
		
		if minetest.get_node(p).name ~= "air"
		or minetest.find_node_near(p, 2, {"nc_terrain:water_source"})
		then return end

		minetest.set_node(p, {name = "nc_terrain:water_source"})
		nodecore.node_sound(p, "place")
		minetest.add_entity(p, modname .. ":waterguard")
	end
})
