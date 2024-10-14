-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, string, vector
    = core, math, nc, string, vector
local math_pi, string_gsub, string_lower
    = math.pi, string.gsub, string.lower
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

function nc.register_raked(basename, desc, opacity, recipematch, recipeidx)
	local name = string_gsub(string_lower(desc), "%W", "_")
	local basedef = core.registered_items[basename] or {}
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
			return core.set_node(pos, {name = basename})
		end,
		on_falling_node_crush = function(pos)
			return core.set_node(pos, {name = basename})
		end
	}
	local linearname = modname .. ":" .. name .. "_raked"
	core.register_node(linearname,
		nc.underride({
				tiles = {
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_linear.png^[opacity:" .. opacity .. ")",
					basedef.tiles[1] .. "^nc_api_loose.png",
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_side.png^[opacity:" .. opacity .. ")"
				},
				on_place = function(itemstack, placer, pointed_thing)
					return core.rotate_and_place(
						itemstack, placer, pointed_thing,
						false, {force_floor = true})
				end
			}, commondef, basedef))

	local nexusname = modname .. ":" .. name .. "_raked_nexus"
	core.register_node(nexusname,
		nc.underride({
				tiles = {
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_nexus.png^[opacity:" .. opacity .. ")",
					basedef.tiles[1] .. "^nc_api_loose.png",
					basedef.tiles[1] .. "^(" .. modname
					.. "_raking_side.png^[opacity:" .. opacity .. ")"
				}
			}, commondef, basedef))

	nc.register_craft({
			label = "rake " .. name,
			action = "pummel",
			wield = {groups = {rakey = true}},
			duration = 0.5,
			normal = {y = 1},
			indexkeys = recipeidx,
			nodes = {{match = recipematch}},
			after = function(pos, data)
				local newnode = {
					name = nexusname,
					param2 = 0
				}

				if data.crafter and data.crafter.getpos
				and data.crafter.get_look_horizontal then
					local ppos = data.crafter:get_pos()
					ppos.y = pos.y
					if vector.distance(pos, ppos) >= 0.4 then
						local dir = data.crafter:get_look_horizontal()
						while dir >= math_pi * 3/4 do dir = dir - math_pi end
						dir = core.yaw_to_dir(dir + math_pi / 4)
						newnode = {
							name = linearname,
							param2 = core.dir_to_facedir(dir)
						}
					end
				end

				local node = data.node or core.get_node(pos)
				if node.name == newnode.name and node.param2 == newnode.param2 then
					newnode = {name = basename}
				end
				if data.crafter then
					nc.wear_wield(data.crafter, {snappy = 1}, 1)
				end
				nc.set_loud(pos, newnode)
				return nc.fallcheck(pos)
			end
		})

	nc.register_craft({
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

nc.register_raked("nc_terrain:sand", "Sand", 96,
	{groups = {sand = true, falling_repose = false}},
	{"group:sand"})
nc.register_raked("nc_terrain:gravel", "Gravel", 160,
	{groups = {gravel = true, falling_repose = false}},
	{"group:gravel"})
nc.register_raked("nc_terrain:dirt", "Dirt", 108,
	{groups = {dirt = true, falling_repose = false}},
	{"group:dirt"})
nc.register_raked("nc_tree:humus", "Humus", 116,
	{groups = {humus = true, falling_repose = false}},
	{"group:humus"})
