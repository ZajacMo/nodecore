-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

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
			local n = minetest.get_meta(pos):get_string("n")
			if n then
				local pl = minetest.get_player_by_name(n)
				if pl and closenough(pos, pl) then return end
			end
			minetest.remove_node(pos)
		end
	})

local function stepcheck(pos, data)
	if not closenough(pos, data.crafter) then return end
	if not data.wield:is_empty() then return end
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	return not nodecore.toolspeed(data.wield, def.groups)
end

local function setstep(pos, node, pname, param2)
	node = {name = modname .. ":" .. node}
	if param2 then node.param2 = param2 end
	minetest.set_node(pos, node)
	minetest.get_meta(pos):set_string("n", pname)
end

local function hangcheck(pos, dx, dy, dz, pname)
	pos = {
		x = pos.x + dx,
		y = pos.y + dy,
		z = pos.z + dz
	}
	if minetest.get_node(pos).name ~= "air" then return end
	setstep(pos, "hang", pname)
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

		local pname = data.pname
		setstep(p, "steps", pname, fd)

		-- invisible support below to simulate hanging by fingertips
		hangcheck(p, 0, -1, 0, pname)
		if dy ~= 0 then
			-- invisible support to the sides to simulate swinging
			-- outward to grab onto the side of an overhang when
			-- hanging below it
			hangcheck(p, 1, -1, 0, pname)
			hangcheck(p, -1, -1, 0, pname)
			hangcheck(p, 0, -1, 1, pname)
			hangcheck(p, 0, -1, -1, pname)
		end
	end
end

nodecore.register_craft({
		label = "scale sheer walls",
		action = "pummel",
		duration = 5,
		normal = {x = 1},
		check = stepcheck,
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
		after = stepafter(1, 0, 0)
	})

nodecore.register_craft({
		label = "scale sheer ceilings",
		action = "pummel",
		duration = 10,
		normal = {y = -1},
		check = stepcheck,
		nodes = {
			{
				match = {walkable = true}
			},
			{
				y = -1,
				match = "air",
				replace = modname .. ":steps"
			}
		},
		after = stepafter(0, -1, 0)
	})
