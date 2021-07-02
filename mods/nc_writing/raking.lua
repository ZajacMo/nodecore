-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local sandname = "nc_terrain:sand"
local sanddef = minetest.registered_items[sandname] or {}
minetest.register_node(modname .. ":sand_raked",
	nodecore.underride({
			description = "Raked Sand",
			tiles = {
				sanddef.tiles[1] .. "^" .. modname
				.. "_raking.png", sanddef.tiles[1]
			},
			paramtype2 = "facedir",
			on_place = function(itemstack, placer, pointed_thing)
				return minetest.rotate_and_place(
					itemstack, placer, pointed_thing,
					false, {force_floor = true})
			end,
			falling_replacement = sandname,
		}, sanddef))

nodecore.register_craft({
		label = "rake sand",
		action = "pummel",
		wield = {groups = {rakey = true}},
		normal = {y = 1},
		indexkeys = {sandname},
		nodes = {{match = sandname}},
		duration = 0.5,
		after = function(pos, data)
			if not (data.crafter and data.crafter.get_look_dir) then return end
			local dir = data.crafter:get_look_dir()
			dir.y = 0
			nodecore.set_loud(pos, {
					name = modname .. ":sand_raked",
					param2 = minetest.dir_to_facedir(dir)
				})
		end
	})
