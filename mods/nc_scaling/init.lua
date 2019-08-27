local modname = minetest.get_current_modname()

local maxdist = 4

minetest.register_node(modname .. ":steps", {
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	tiles = {
		"nc_scaling_blank.png",
		"nc_scaling_blank.png",
		"nc_scaling_blank.png",
		"nc_scaling_blank.png",
		"nc_scaling_blank.png",
		"nc_scaling_steps.png"
	},
	use_texture_alpha = true,
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(-0.5, -0.5, 31/64, 0.5, 0.5, 0.5),
	walkable = false,
	climbable = true,
	pointable = false,
	buildable_to = true
})

nodecore.register_limited_abm({
	label = "Scaling Decay",
	interval = 1,
	chance = 1,
	limited_max = 100,
	nodenames = {modname .. ":steps"},
	action = function(pos)
		local n = minetest.get_meta(pos):get_string("n")
		if n then
			local pl = minetest.get_player_by_name(n)
			if pl and vector.distance(pl:get_pos(), pos) <= maxdist
			then return end
		end
		minetest.remove_node(pos)
	end
})

nodecore.register_craft({
	label = "compress coal block",
	action = "pummel",
	duration = 5,
	normal = {x = 1},
	check = function(pos, data)
		if vector.distance(data.crafter:get_pos(), pos) > maxdist then return end
		if not data.wield:is_empty() then return end
		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		return not nodecore.toolspeed(data.wield, def.groups)
	end,
	nodes = {
		{
			match = {walkable = true}
		},
		{
			x = 1,
			match = "air",
			replace = modname .. ":steps"
		}
	},
	after = function(pos, data)
		local p = data.rel(1, 0, 0)
		local d = vector.subtract(p, pos)
		local fd = 0
		for i = 0, #nodecore.facedirs do
			if vector.equals(nodecore.facedirs[i].f, d) then
				fd = i
				break
			end
		end
		minetest.set_node(p, {name = modname .. ":steps", param2 = fd})
		minetest.get_meta(p):set_string("n", data.pname)
	end
})