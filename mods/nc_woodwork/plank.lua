-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local plank = modname .. ":plank"
minetest.register_node(plank, {
		description = "Wooden Plank",
		tiles = {modname .. "_plank.png"},
		groups = {
			choppy = 1,
			flammable = 2,
			fire_fuel = 5,
			nc_door_scuff_opacity = 72
		},
		sounds = nodecore.sounds("nc_tree_woody")
	})

local function backstop(pos, dir, depth)
	if depth <= 0 then return end
	pos = vector.add(pos, dir)
	if nodecore.buildable_to(pos) then return end
	if nodecore.node_group("falling_node", pos) then
		return backstop(pos, dir, depth - 1)
	end
	return true
end

local function check_backstop(pos, data)
	return backstop(pos, vector.subtract(data.pointed.under, data.pointed.above), 4)
end

local function check_x(_, data)
	local x = nodecore.facedirs[data.node.param2].t.x
	return x == 1 or x == -1
end

local function check_y(_, data)
	local y = nodecore.facedirs[data.node.param2].t.y
	return y == 1 or y == -1
end

local function check_z(_, data)
	local z = nodecore.facedirs[data.node.param2].t.z
	return z == 1 or z == -1
end

local function check_x_with_backstop(pos, data)
	return check_x(pos, data) and check_backstop(pos, data)
end

local function check_y_with_backstop(pos, data)
	return check_y(pos, data) and check_backstop(pos, data)
end

local function check_z_with_backstop(pos, data)
	return check_z(pos, data) and check_backstop(pos, data)
end

local function check_downwards(pos, data)
	if not check_y(pos, data) then return end
	pos = vector.add(pos, vector.subtract(data.pointed.under, data.pointed.above))
	if nodecore.buildable_to(pos) then return end
	return true
end

local function split_recipe(choppy, normal, check)
	nodecore.register_craft({
			label = "split tree to planks",
			action = "pummel",
			toolgroups = {choppy = choppy},
			normal = normal,
			check = check,
			indexkeys = {"group:log"},
			nodes = {
				{match = {groups = {log = true}}, replace = "air"}
			},
			items = {
				{name = plank, count = 4, scatter = 5}
			}
		})
end

split_recipe(1, {x =  1}, check_x_with_backstop)
split_recipe(1, {x = -1}, check_x_with_backstop)
split_recipe(1, {y =  1}, check_downwards)
split_recipe(1, {y = -1}, check_y_with_backstop)
split_recipe(1, {z =  1}, check_z_with_backstop)
split_recipe(1, {z = -1}, check_z_with_backstop)

split_recipe(4, {x =  1}, check_x)
split_recipe(4, {x = -1}, check_x)
split_recipe(4, {y =  1}, check_y)
split_recipe(4, {y = -1}, check_y)
split_recipe(4, {z =  1}, check_z)
split_recipe(4, {z = -1}, check_z)

nodecore.register_craft({
		label = "bash planks to sticks",
		action = "pummel",
		toolgroups = {thumpy = 3},
		check = check_backstop,
		indexkeys = {plank},
		nodes = {
			{match = plank, replace = "air"}
		},
		items = {
			{name = "nc_tree:stick 2", count = 4, scatter = 5}
		}
	})
