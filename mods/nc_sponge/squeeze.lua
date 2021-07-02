-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local spongedirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1}
}

local spongewet = modname .. ":sponge_wet"

nodecore.register_craft({
		label = "squeeze sponge",
		action = "pummel",
		toolgroups = {thumpy = 1},
		indexkeys = {spongewet},
		nodes = {
			{
				match = spongewet
			}
		},
		after = function(pos)
			local found
			for _, d in pairs(spongedirs) do
				local p = vector.add(pos, d)
				if nodecore.artificial_water(p, {
						matchpos = pos,
						match = spongewet,
						minttl = 1,
						maxttl = 10
					}) then found = true end
			end
			if found then nodecore.node_sound(pos, "dig") end
		end
	})
