-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local bark = "nc_tree_tree_side.png^[mask:nc_api_storebox_frame.png"

core.register_node(modname .. ":form", {
		description = "Wooden Form",
		tiles = {bark},
		selection_box = nc.fixedbox(),
		collision_box = nc.fixedbox(),
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
		sounds = nc.sounds("nc_tree_sticky"),
		storebox_access = function() return true end,
		on_ignite = function(pos)
			if core.get_node(pos).name == modname .. ":form" then
				return nc.stack_get(pos)
			end
		end,
		mapcolor = {r = 79, g = 54, b = 31, a = 128},
	})

local function regconv(from, to)
	return nc.register_craft({
			label = "wooden " .. from .. " to " .. to,
			action = "pummel",
			toolgroups = {thumpy = 1},
			indexkeys = {modname .. ":" .. from},
			check = function(pos)
				return nc.stack_get(pos):is_empty()
			end,
			nodes = {
				{match = modname .. ":" .. from, replace = modname .. ":" .. to}
			}
		})
end
regconv("frame", "form")
regconv("form", "frame")

local braced = "nc_tree_tree_side.png^[mask:nc_woodwork_form_braced.png"

core.register_node(modname .. ":form_braced", {
		description = "Braced Wooden Form",
		tiles = {braced},
		selection_box = nc.fixedbox(),
		collision_box = nc.fixedbox(),
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
		sounds = nc.sounds("nc_tree_sticky"),
		storebox_access = function() return true end,
		on_ignite = function(pos)
			if core.get_node(pos).name == modname .. ":form_braced" then
				return nc.stack_get(pos)
			end
		end,
		mapcolor = {r = 79, g = 54, b = 31, a = 128},
	})

nc.register_craft({
		label = "assemble braced wood form",
		action = "stackapply",
		indexkeys = {modname .. ":form"},
		wield = {name = "nc_tree:stick"},
		consumewield = 1,
		nodes = {
			{
				match = {name = modname .. ":form", empty = true},
				replace = modname .. ":form_braced"
			},
		}
	})

local plank = modname .. "_plank.png^(" .. bark .. ")"

core.register_node(modname .. ":shelf", {
		description = "Wooden Shelf",
		tiles = {bark, plank},
		selection_box = nc.fixedbox(),
		collision_box = nc.fixedbox(),
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
		sounds = nc.sounds("nc_tree_woody"),
		storebox_access = function(pt) return pt.above.y == pt.under.y end,
		on_ignite = function(pos)
			if core.get_node(pos).name == modname .. ":shelf" then
				return nc.stack_get(pos)
			end
		end,
		mapcolor = {r = 77, g = 50, b = 25},
	})

nc.register_craft({
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
