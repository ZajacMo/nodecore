-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_limited_abm({
	label = "Lux Reaction",
	interval = 1,
	chance = 2,
	limited_max = 100,
	nodenames = {"group:lux_cobble"},
	action = function(pos, node)
		local minp = vector.subtract(pos, {x = 1, y = 1, z = 1})
		local maxp = vector.add(pos, {x = 1, y = 1, z = 1})
		local qty = #minetest.find_nodes_in_area(minp, maxp, {"group:lux_emit"})
		qty = math_ceil(qty / 2)
		if qty > 8 then qty = 8 end
		local name = node.name:gsub("cobble%d", "cobble" .. qty)
		if name == node.name then return end
		minetest.set_node(pos, {name = name})
	end
})
