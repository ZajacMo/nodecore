-- LUALOCALS < ---------------------------------------------------------
local core, nc, string
    = core, nc, string
local string_lower
    = string.lower
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local txr_frame = modname .. "_glass_edges.png^(nc_tree_tree_side.png^[mask:"
.. modname .. "_tank_mask.png)"

local function register_tank(subname, desc, pane, recipeitem, alpha)
	local tankname = modname .. ":" .. subname
	core.register_node(tankname, {
			description = desc .. " Glass Case",
			tiles = {
				pane .. txr_frame,
				pane .. txr_frame,
				txr_frame
			},
			selection_box = nc.fixedbox(),
			collision_box = nc.fixedbox(),
			groups = {
				silica = 1,
				silica_clear = 1,
				cracky = 3,
				flammable = 20,
				fire_fuel = 2,
				visinv = 1,
				storebox = 1,
				totable = 1,
				scaling_time = 200,
				storebox_sealed = 1
			},
			paramtype = "light",
			sunlight_propagates = true,
			air_pass = false,
			sounds = nc.sounds("nc_optics_glassy"),
			storebox_access = function(pt) return pt.above.y > pt.under.y end,
			on_ignite = function(pos)
				if core.get_node(pos).name == tankname then
					return {modname .. ":glass_crude", nc.stack_get(pos)}
				end
				return modname .. ":glass_crude"
			end,
			mapcolor = {r = 255, g = 255, b = 255, a = alpha},
		})

	nc.register_craft({
			label = "assemble " .. string_lower(desc) .. " glass case",
			action = "stackapply",
			indexkeys = {"nc_woodwork:form"},
			wield = {name = recipeitem},
			consumewield = 1,
			nodes = {
				{
					match = {name = "nc_woodwork:form", empty = true},
					replace = tankname
				},
			}
		})
end

register_tank("shelf", "Clear", modname .. "_glass_glare.png^", modname .. ":glass", 128)
register_tank("shelf_float", "Float", "", modname .. ":glass_float", 80)
