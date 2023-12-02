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
		sounds = nodecore.sounds("nc_tree_woody"),
		mapcolor = {r = 180, g = 144, b = 89},
	})

local function split_recipe(choppy, subcheck)
	nodecore.register_craft({
			label = "split tree to planks",
			action = "pummel",
			toolgroups = {choppy = choppy},
			check = function(pos, data)
				local dir = vector.subtract(data.pointed.under, data.pointed.above)
				local top = nodecore.facedirs[data.node.param2].t

				-- Must be striking the end, not side
				if (dir.x == 0) ~= (top.x == 0)
				or (dir.y == 0) ~= (top.y == 0)
				or (dir.z == 0) ~= (top.z == 0) then return end

				return (not subcheck) or subcheck(pos, data, dir, top)
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

split_recipe(1, function(pos, _, dir)
		-- Downward splitting direction works without a backstop.
		if dir.y == -1 then return true end

		-- Any other direction works with an adequate backstop.
		return nodecore.node_backstop(pos, dir, 4)
	end)

-- Lode tier or better can chop in any direction freely.
-- The blade is sharp enough that no backstop is needed beyond
-- the inertia of the log itself.
split_recipe(4)

local function bash_recipe(thumpy, check)
	nodecore.register_craft({
			label = "bash planks to sticks",
			action = "pummel",
			toolgroups = {thumpy = thumpy},
			check = check,
			indexkeys = {plank},
			nodes = {
				{match = plank, replace = "air"}
			},
			items = {
				{name = "nc_tree:stick 2", count = 4, scatter = 5}
			}
		})
end

-- Stone mallet can bash downward, OR any direction with a backstop.
bash_recipe(3, function(pos, data)
		local dir = vector.subtract(data.pointed.under, data.pointed.above)
		return dir.y == -1 or nodecore.node_backstop(pos, dir, 4)
	end)

-- Tempered lode can bash in any direction freely.
bash_recipe(5)
