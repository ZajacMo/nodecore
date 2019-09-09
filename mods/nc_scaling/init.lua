-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

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
		buildable_to = true,
		air_equivalent = true,
		light_source = 1,
		groups = {[modname] = 1}
	})

minetest.register_node(modname .. ":hang", {
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "airlike",
		walkable = false,
		climbable = true,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		groups = {[modname] = 1}
	})

minetest.register_node(modname .. ":see", {
		paramtype = "light",
		sunlight_propagates = true,
		tiles = {
			"nc_scaling_steps.png",
			"nc_scaling_blank.png"
		},
		use_texture_alpha = true,
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-0.5, -0.5, -0.5, 0.5, -31/64, 0.5),
		walkable = false,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		light_source = 1,
		groups = {[modname] = 1}
	})

local function closenough(pos, player)
	local pp = player:get_pos()
	pp.y = pp.y + 1
	return vector.distance(pos, pp) <= 5
end

nodecore.register_limited_abm({
		label = "Scaling Decay",
		interval = 1,
		chance = 1,
		limited_max = 100,
		nodenames = {"group:" .. modname},
		action = function(pos)
			local data = minetest.get_meta(pos):get_string("data")
			if (not data) or (data == "") then
				return minetest.remove_node(pos)
			end
			data = minetest.deserialize(data)
			if minetest.get_node(data.pos).name ~= data.node then
				return minetest.remove_node(pos)
			end
			for _, p in pairs(minetest.get_connected_players()) do
				if closenough(pos, p) then return end
			end
			return minetest.remove_node(pos)
		end
	})

local function stepcheck(pos, data)
	if not closenough(pos, data.crafter) then return end
	if not data.wield:is_empty() then return end
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	return not nodecore.toolspeed(data.wield, def.groups)
end

local function setstep(pos, node, mdata, param2)
	node = {name = modname .. ":" .. node}
	if param2 then node.param2 = param2 end
	minetest.set_node(pos, node)
	minetest.get_meta(pos):set_string("data",
		minetest.serialize(mdata))
end

local function hangcheck(pos, dx, dy, dz, mdata)
	pos = {
		x = pos.x + dx,
		y = pos.y + dy,
		z = pos.z + dz
	}
	if minetest.get_node(pos).name ~= "air" then return end
	setstep(pos, "hang", mdata)
end

local function stepafter(dx, dy, dz)
	return function(pos, data)
		local p = data.rel(dx, dy, dz)

		local d = vector.subtract(p, pos)
		local fd = 0
		for i = 0, #nodecore.facedirs do
			if vector.equals(nodecore.facedirs[i].f, d) then
				fd = i
				break
			end
		end

		nodecore.node_sound(pos, "place")

		local mdata = {
			pos = pos,
			node = data.node.name
		}
		setstep(p, "steps", mdata, fd)

		-- invisible support below to simulate hanging by fingertips
		hangcheck(p, 0, -1, 0, mdata)
		if dy ~= 0 then
			-- invisible support to the sides to simulate swinging
			-- outward to grab onto the side of an overhang when
			-- hanging below it
			hangcheck(p, 1, -1, 0, mdata)
			hangcheck(p, -1, -1, 0, mdata)
			hangcheck(p, 0, -1, 1, mdata)
			hangcheck(p, 0, -1, -1, mdata)
		end
	end
end

local pumparticles = {
	minsize = 1,
	maxsize = 5,
	forcetexture = "nc_scaling_particle.png",
	glow = 1
}

nodecore.register_craft({
		label = "scale sheer walls",
		action = "pummel",
		pumparticles = pumparticles,
		duration = 5,
		normal = {x = 1},
		check = stepcheck,
		nodes = {
			{
				match = {walkable = true}
			},
			{
				x = 1,
				match = {any = {"air", modname .. ":hang"}}
			}
		},
		after = stepafter(1, 0, 0)
	})

nodecore.register_craft({
		label = "scale sheer ceilings",
		action = "pummel",
		pumparticles = pumparticles,
		duration = 10,
		normal = {y = -1},
		check = stepcheck,
		nodes = {
			{
				match = {walkable = true}
			},
			{
				y = -1,
				match = "air"
			}
		},
		after = stepafter(0, -1, 0)
	})

nodecore.register_craft({
		label = "scale sheer floors",
		action = "pummel",
		pumparticles = pumparticles,
		duration = 5,
		normal = {y = 1},
		check = stepcheck,
		nodes = {
			{
				match = {walkable = true}
			},
			{
				y = 1,
				match = {any = {"air", modname .. ":hang"}},
				replace = modname .. ":see"
			}
		},
		after = function(pos)
			minetest.get_meta({x = pos.x, y = pos.y + 1, z = pos.z})
			:set_string("data", minetest.serialize({
						pos = pos,
						node = minetest.get_node(pos).name
					}))
		end
	})
