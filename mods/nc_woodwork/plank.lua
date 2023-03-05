-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
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
    local dir = vector.subtract(data.pointed.under, data.pointed.above)
    if dir.y == -1 then
	    if nodecore.buildable_to(vector.add(pos, dir)) then return end
	    return true
    else return backstop(pos, dir, 4)
    end
end

local function split_recipe(choppy, backstop)
    for _, dir in pairs(nodecore.dirs()) do
	    nodecore.register_craft({
			    label = "split tree to planks",
			    action = "pummel",
			    toolgroups = {choppy = choppy},
			    normal = dir,
			    check = function(pos, data)
                    return (vector.equals(dir, nodecore.facedirs[data.node.param2].t)
                        or vector.equals(dir, nodecore.facedirs[data.node.param2].b))
                        and (not backstop or check_backstop(pos, data))
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
end

split_recipe(1, true)
split_recipe(4, false)

local function bash_recipe(thumpy, backstop)
    nodecore.register_craft({
		label = "bash planks to sticks",
		action = "pummel",
		toolgroups = {thumpy = thumpy},
		check = function (pos, data)
            return not backstop or check_backstop(pos, data)
        end,
		indexkeys = {plank},
		nodes = {
			{match = plank, replace = "air"}
		},
		items = {
			{name = "nc_tree:stick 2", count = 4, scatter = 5}
		}
	})
end

bash_recipe(3, true)
bash_recipe(5, false)
