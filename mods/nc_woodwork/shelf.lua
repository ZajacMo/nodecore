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
			snappy = 1,
			flammable = 2,
			fire_fuel = 1,
			totable = 1,
			storebox = 1,
			visinv = 1,
			container = 0
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_tree_sticky"),
		on_ignite = function(pos)
			if minetest.get_node(pos).name == modname .. ":form" then
				return nodecore.stack_get(pos)
			end
		end,
		on_settle_item = function(pos, node, stack, inside, ...)
			if inside and nodecore.stack_can_fall_in({
					x = pos.x,
					y = pos.y - 1,
					z = pos.z
				}, stack) then return stack end
			return nodecore.storebox_on_settle_item(pos, node, stack, inside, ...)
		end,
		on_stack_change = function(pos, _, stack)
			if stack:is_empty() then return end
			print(stack:to_string())
			if not nodecore.stack_can_fall_in({
					x = pos.x,
					y = pos.y - 1,
					z = pos.z
				}, stack) then return end
			nodecore.stack_set(pos, "")
			nodecore.item_eject(pos, stack)
		end
	})

local function regconv(from, to)
	return nodecore.register_craft({
			label = "wooden " .. from .. " to " .. to,
			action = "pummel",
			toolgroups = {thumpy = 1},
			indexkeys = {modname .. ":" .. from},
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
		norotate = true,
		indexkeys = {modname .. ":plank"},
		nodes = {
			{match = modname .. ":plank", replace = "air"},
			{x = -1, z = -1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 1, z = -1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = -1, z = 1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 1, z = 1, match = modname .. ":frame", replace = modname .. ":shelf"},
		}
	})

nodecore.register_craft({
		label = "assemble wood shelf",
		norotate = true,
		indexkeys = {modname .. ":plank"},
		nodes = {
			{match = modname .. ":plank", replace = "air"},
			{x = 0, z = -1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 0, z = 1, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = -1, z = 0, match = modname .. ":frame", replace = modname .. ":shelf"},
			{x = 1, z = 0, match = modname .. ":frame", replace = modname .. ":shelf"},
		}
	})
