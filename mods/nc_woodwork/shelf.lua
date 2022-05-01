-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local bark = "nc_tree_tree_side.png^[mask:nc_api_storebox_frame.png"

minetest.register_node(modname .. ":form", {
		description = "Wooden Form",
		tiles = {bark},
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			choppy = 1,
			flammable = 2,
			fire_fuel = 1,
			totable = 1,
			storebox = 1,
			visinv = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_tree_sticky"),
		storebox_access = function() return true end,
		on_ignite = function(pos)
			if minetest.get_node(pos).name == modname .. ":form" then
				return nodecore.stack_get(pos)
			end
		end
	})

local function regconv(from, to)
	return nodecore.register_craft({
			label = "wooden " .. from .. " to " .. to,
			action = "pummel",
			toolgroups = {thumpy = 1},
			indexkeys = {modname .. ":" .. from},
			check = function(pos)
				return nodecore.stack_get(pos):is_empty()
			end,
			nodes = {
				{match = modname .. ":" .. from, replace = modname .. ":" .. to}
			}
		})
end
regconv("frame", "form")
regconv("form", "frame")

local plank = modname .. "_plank.png^(" .. bark .. ")"

minetest.register_node(modname .. ":shelf", {
		description = "Wooden Shelf",
		tiles = {bark, plank},
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			choppy = 1,
			visinv = 1,
			flammable = 2,
			fire_fuel = 3,
			storebox = 1,
			totable = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sounds = nodecore.sounds("nc_tree_woody"),
		storebox_access = function(pt) return pt.above.y == pt.under.y end,
		on_ignite = function(pos)
			if minetest.get_node(pos).name == modname .. ":shelf" then
				return nodecore.stack_get(pos)
			end
		end
	})

nodecore.register_craft({
		label = "assemble wood shelf",
		action = "stackapply",
		indexkeys = {modname .. ":form"},
		wield = {name = modname .. ":plank"},
		consumewield = 1,
		nodes = {
			{
				match = {name = modname .. ":form", empty = true},
				replace = modname .. ":shelf"
			},
		}
	})
