-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_pi
    = math.pi
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local sandname = "nc_terrain:sand"
local sanddef = minetest.registered_items[sandname] or {}
minetest.register_node(modname .. ":sand_raked",
	nodecore.underride({
			description = "Raked Sand",
			tiles = {
				sanddef.tiles[1] .. "^" .. modname
				.. "_raking_linear.png",
				sanddef.tiles[1],
				sanddef.tiles[1] .. "^" .. modname
				.. "_raking_side.png"
			},
			paramtype2 = "facedir",
			on_place = function(itemstack, placer, pointed_thing)
				return minetest.rotate_and_place(
					itemstack, placer, pointed_thing,
					false, {force_floor = true})
			end,
			falling_replacement = sandname,
			silktouch_as = sandname
		}, sanddef))
minetest.register_node(modname .. ":sand_raked_nexus",
	nodecore.underride({
			description = "Raked Sand",
			tiles = {
				sanddef.tiles[1] .. "^" .. modname
				.. "_raking_nexus.png",
				sanddef.tiles[1],
				sanddef.tiles[1] .. "^" .. modname
				.. "_raking_side.png"
			},
			paramtype2 = "facedir",
			on_place = function(itemstack, placer, pointed_thing)
				return minetest.rotate_and_place(
					itemstack, placer, pointed_thing,
					false, {force_floor = true})
			end,
			falling_replacement = sandname,
			silktouch_as = sandname
		}, sanddef))

nodecore.register_craft({
		label = "rake sand",
		action = "pummel",
		wield = {groups = {rakey = true}},
		duration = 0.5,
		normal = {y = 1},
		indexkeys = {"group:sand"},
		nodes = {{match = {groups = {sand = true, falling_repose = false}}}},
		after = function(pos, data)
			if not (data.crafter and data.crafter.getpos
				and data.crafter.get_look_horizontal) then return end

			local newnode
			local ppos = data.crafter:get_pos()
			ppos.y = pos.y
			if vector.distance(pos, ppos) < 0.4 then
				newnode = {
					name = modname .. ":sand_raked_nexus",
					param2 = 0
				}
			else
				local dir = data.crafter:get_look_horizontal()
				while dir >= math_pi * 3/4 do dir = dir - math_pi end
				dir = minetest.yaw_to_dir(dir + math_pi / 4)
				newnode = {
					name = modname .. ":sand_raked",
					param2 = minetest.dir_to_facedir(dir)
				}
			end

			local node = data.node or minetest.get_node(pos)
			if node.name == newnode.name and node.param2 == newnode.param2 then
				newnode = {name = sandname}
			end
			nodecore.wear_wield(data.crafter, {snappy = 1}, 1)
			return nodecore.set_loud(pos, newnode)
		end
	})
