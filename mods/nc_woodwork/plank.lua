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

local function splitrecipe(choppy, normaly)
	nodecore.register_craft({
			label = "split tree to planks",
			action = "pummel",
			toolgroups = {choppy = choppy},
			normal = {y = normaly},
			check = function(_, data)
				local y = nodecore.facedirs[data.node.param2].t.y
				return y == 1 or y == -1
			end,
			indexkeys = {"group:log"},
			nodes = {
				{match = {groups = {log = true}}, replace = "air"}
			},
			items = {
				{name = plank, count = 4, scatter = 5}
			}
		})
end
splitrecipe(1, 1)
splitrecipe(4, -1)

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
