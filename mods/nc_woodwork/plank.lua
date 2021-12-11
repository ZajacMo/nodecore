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
			fire_fuel = 5
		},
		sounds = nodecore.sounds("nc_tree_woody")
	})

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

local function bashrecipe(thumpy, normaly)
	nodecore.register_craft({
			label = "bash planks to sticks",
			action = "pummel",
			toolgroups = {thumpy = thumpy},
			normal = {y = normaly},
			indexkeys = {plank},
			nodes = {
				{match = plank, replace = "air"}
			},
			items = {
				{name = "nc_tree:stick 2", count = 4, scatter = 5}
			}
		})
end
bashrecipe(3, 1)
bashrecipe(5, -1)
