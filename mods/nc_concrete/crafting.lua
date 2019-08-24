-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local ashdirs = {
	{x = 1, y = -1, z = 0},
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 1},
	{x = 0, y = -1, z = -1}
}

nodecore.register_craft({
	label = "mix concrete (fail)",
	action = "pummel",
	priority = 2,
	toolgroups = {thumpy = 1},
	normal = {y = 1},
	nodes = {
		{
			match = "nc_terrain:gravel_loose"
		},
		{
			x = 1,
			y = -1,
			match = {buildable_to = true}
		},
		{
			y = -1,
			match = "nc_fire:ash",
			replace = "air"
		}
	},
	after = function(pos)
		local dirs = {}
		for _, d in pairs(ashdirs) do
			local p = vector.add(pos, d)
			if nodecore.buildable_to(p) then
				dirs[#dirs + 1] = {pos = p, qty = 0}
			end
		end
		for n = 1, 8 do
			local p = dirs[math_random(1, #dirs)]
			p.qty = p.qty + 1
		end
		for _, v in pairs(dirs) do
			if v.qty > 0 then
				nodecore.item_eject(v.pos, "nc_fire:lump_ash " .. v.qty)
			end
		end
	end
})

nodecore.register_craft({
	label = "mix concrete",
	action = "pummel",
	priority = 1,
	toolgroups = {thumpy = 1},
	normal = {y = 1},
	nodes = {
		{
			match = "nc_terrain:gravel_loose",
			replace = "air"
		},
		{
			y = -1,
			match = "nc_fire:ash",
			replace = modname .. ":aggregate"
		}
	}
})
