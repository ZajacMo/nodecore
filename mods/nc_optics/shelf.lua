-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string
    = minetest, nodecore, string
local string_lower
    = string.lower
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local txr_frame = modname .. "_glass_edges.png^(nc_tree_tree_side.png^[mask:"
.. modname .. "_tank_mask.png)"

local function register_tank(subname, desc, pane, recipeitem)
	local tankname = modname .. ":" .. subname
	minetest.register_node(tankname, {
			description = desc .. " Glass Case",
			tiles = {
				pane .. txr_frame,
				pane .. txr_frame,
				txr_frame
			},
			selection_box = nodecore.fixedbox(),
			collision_box = nodecore.fixedbox(),
			groups = {
				silica = 1,
				silica_clear = 1,
				cracky = 3,
				flammable = 20,
				fire_fuel = 2,
				visinv = 1,
				storebox = 1,
				totable = 1,
				scaling_time = 200
			},
			paramtype = "light",
			sunlight_propagates = true,
			air_pass = false,
			sounds = nodecore.sounds("nc_optics_glassy"),
			storebox_access = function(pt) return pt.above.y > pt.under.y end,
			on_ignite = function(pos)
				if minetest.get_node(pos).name == tankname then
					return {modname .. ":glass_crude", nodecore.stack_get(pos)}
				end
				return modname .. ":glass_crude"
			end
		})

	local craftlabel = "assemble " .. string_lower(desc) .. " glass case"
	nodecore.register_craft({
			label = craftlabel,
			norotate = true,
			indexkeys = {"nc_woodwork:frame"},
			nodes = {
				{match = "nc_woodwork:frame", replace = "air"},
				{x = -1, z = -1, match = recipeitem, replace = tankname},
				{x = 1, z = -1, match = recipeitem, replace = tankname},
				{x = -1, z = 1, match = recipeitem, replace = tankname},
				{x = 1, z = 1, match = recipeitem, replace = tankname},
				{x = 0, z = -1, match = "nc_woodwork:staff", replace = "air"},
				{x = 0, z = 1, match = "nc_woodwork:staff", replace = "air"},
				{x = -1, z = 0, match = "nc_woodwork:staff", replace = "air"},
				{x = 1, z = 0, match = "nc_woodwork:staff", replace = "air"},
			}
		})
	nodecore.register_craft({
			label = craftlabel,
			norotate = true,
			indexkeys = {"nc_woodwork:frame"},
			nodes = {
				{match = "nc_woodwork:frame", replace = "air"},
				{x = 0, z = -1, match = recipeitem, replace = tankname},
				{x = 0, z = 1, match = recipeitem, replace = tankname},
				{x = -1, z = 0, match = recipeitem, replace = tankname},
				{x = 1, z = 0, match = recipeitem, replace = tankname},
				{x = -1, z = -1, match = "nc_woodwork:staff", replace = "air"},
				{x = 1, z = 1, match = "nc_woodwork:staff", replace = "air"},
				{x = -1, z = 1, match = "nc_woodwork:staff", replace = "air"},
				{x = 1, z = -1, match = "nc_woodwork:staff", replace = "air"},
			}
		})
end

register_tank("shelf", "Clear", modname .. "_glass_glare.png^", modname .. ":glass")
register_tank("shelf_float", "Float", "", modname .. ":glass_float")
