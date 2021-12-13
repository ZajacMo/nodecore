-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string, vector
    = math, minetest, nodecore, string, vector
local math_pi, string_gsub, string_lower
    = math.pi, string.gsub, string.lower
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_raked(basename, desc, opacity, recipematch, recipeidx)
	local name = string_gsub(string_lower(desc), "%W", "_")
	local basedef = minetest.registered_items[basename] or {}
	local commondef = {
		description = "Raked " .. desc,
		paramtype2 = "facedir",
		falling_replacement = basename,
		silktouch_as = basename,
		groups = {
			raked = 1,
			[name .. "_raked"] = 1,
			falling_node = 1,
			soil = basedef.groups and basedef.groups.soil
			and (basedef.groups.soil + 2) or nil
		},
		on_door_conveyed = function(pos)
			return minetest.set_node(pos, {name = basename})
		end,
		on_falling_node_crush = function(pos)
			return minetest.set_node(pos, {name = basename})
		end
	}
	local linearname = modname .. ":" .. name .. "_raked"
	minetest.register_node(linearname,
		nodecore.underride({
				tiles = {
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_linear.png^[opacity:" .. opacity .. ")",
					basedef.tiles[1] .. "^nc_api_loose.png",
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_side.png^[opacity:" .. opacity .. ")"
				},
				on_place = function(itemstack, placer, pointed_thing)
					return minetest.rotate_and_place(
						itemstack, placer, pointed_thing,
						false, {force_floor = true})
				end
			}, commondef, basedef))

	local nexusname = modname .. ":" .. name .. "_raked_nexus"
	minetest.register_node(nexusname,
		nodecore.underride({
				tiles = {
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_nexus.png^[opacity:" .. opacity .. ")",
					basedef.tiles[1] .. "^nc_api_loose.png",
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_side.png^[opacity:" .. opacity .. ")"
				}
			}, commondef, basedef))

	nodecore.register_craft({
			label = "rake " .. name,
			action = "pummel",
			wield = {groups = {rakey = true}},
			duration = 0.5,
			normal = {y = 1},
			indexkeys = recipeidx,
			nodes = {{match = recipematch}},
			after = function(pos, data)
				if not (data.crafter and data.crafter.getpos
					and data.crafter.get_look_horizontal) then return end

				local newnode
				local ppos = data.crafter:get_pos()
				ppos.y = pos.y
				if vector.distance(pos, ppos) < 0.4 then
					newnode = {
						name = nexusname,
						param2 = 0
					}
				else
					local dir = data.crafter:get_look_horizontal()
					while dir >= math_pi * 3/4 do dir = dir - math_pi end
					dir = minetest.yaw_to_dir(dir + math_pi / 4)
					newnode = {
						name = linearname,
						param2 = minetest.dir_to_facedir(dir)
					}
				end

				local node = data.node or minetest.get_node(pos)
				if node.name == newnode.name and node.param2 == newnode.param2 then
					newnode = {name = basename}
				end
				nodecore.wear_wield(data.crafter, {snappy = 1}, 1)
				return nodecore.set_loud(pos, newnode)
			end
		})

	nodecore.register_craft({
			label = "un-rake " .. name,
			action = "pummel",
			toolgroups = {thumpy = 1},
			normal = {y = 1},
			indexkeys = {"group:" .. name .. "_raked"},
			nodes = {{
					match = {groups = {[name .. "_raked"] = true}},
					replace = basename
			}},
		})
end

nodecore.register_raked("nc_terrain:sand", "Sand", 96,
	{groups = {sand = true, falling_repose = false}},
	{"group:sand"})
nodecore.register_raked("nc_terrain:gravel", "Gravel", 160,
	{groups = {gravel = true, falling_repose = false}},
	{"group:gravel"})
nodecore.register_raked("nc_terrain:dirt", "Dirt", 108,
	{groups = {dirt = true, falling_repose = false}},
	{"group:dirt"})
nodecore.register_raked("nc_tree:humus", "Humus", 116,
	{groups = {humus = true, falling_repose = false}},
	{"group:humus"})
