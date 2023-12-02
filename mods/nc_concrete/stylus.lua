-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs
    = ItemStack, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_tool(modname .. ":stylus", {
		description = "Stone-Tipped Stylus",
		tool_wears_to = "nc_tree:stick",
		inventory_image = modname .. "_tool_stylus.png",
		groups = {
			flammable = 2,
			nc_doors_pummel_first = 1
		},
		tool_capabilities = nodecore.toolcaps({
				scratchy = 3
			}),
		on_ignite = "nc_stonework:chip",
		sounds = nodecore.sounds("nc_terrain_stony"),
		on_stack_touchtip = function(stack, desc)
			local patt = stack:get_meta():get_string("pattern")
			if not patt then return desc end
			for _, def in pairs(nodecore.registered_concrete_patterns) do
				if patt == def.name and def.description then
					return desc .. "\n" .. def.description
				end
			end
			return desc
		end
	})

nodecore.register_craft({
		label = "assemble stylus",
		normal = {y = 1},
		indexkeys = {"nc_stonework:chip"},
		nodes = {
			{match = "nc_stonework:chip", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = "air"},
		},
		after = function(pos)
			pos.y = pos.y - 1
			local item = ItemStack(modname .. ":stylus")
			item:get_meta():set_string("pattern",
				nodecore.pickrand(nodecore.registered_concrete_patterns).name)
			return nodecore.item_eject(pos, item)
		end
	})

local function getdefs(node)
	local def = minetest.registered_items[node.name] or {}
	return def.pattern_def, def.etch_def
end

local function setply(pos, nodename, player)
	local node = {name = nodename}
	if minetest.registered_nodes[node.name].paramtype2 == "4dir"
	and player then
		node.param2 = minetest.dir_to_fourdir(
			player:get_look_dir())
	end
	nodecore.set_loud(pos, node)
end
nodecore.register_craft({
		label = "stylus etch",
		action = "pummel",
		toolgroups = {scratchy = 1},
		indexkeys = {"group:concrete_etchable"},
		nodes = {
			{
				match = {groups = {concrete_etchable = true}}
			}
		},
		after = function(pos, data)
			local pattdef, etchdef = getdefs(minetest.get_node(pos))
			if not (pattdef and etchdef) then return end
			local setpref = modname .. ":" .. etchdef.name .. "_"

			local wield = data.wield
			if (not wield) or wield:is_empty() then return end
			local wieldpatt = wield:get_meta():get_string("pattern")
			if wieldpatt and wieldpatt ~= "" and wieldpatt ~= pattdef.name then
				setply(pos, setpref .. wieldpatt .. "_ply", data.crafter)
				return
			end

			local nxpatt = pattdef.next.name
			setply(pos, setpref .. nxpatt .. "_ply", data.crafter)
			wield:get_meta():set_string("pattern", nxpatt)
			if data.crafter then
				nodecore.player_discover(data.crafter, "stylus train")
				data.crafter:set_wielded_item(data.wield)
			elseif data.presstoolpos then
				nodecore.witness(pos, "stylus train")
				nodecore.stack_set(data.presstoolpos, wield)
			end
		end
	})

nodecore.register_soaking_abm({
		label = "pliable concrete cure",
		interval = 1,
		nodenames = {"group:concrete_etchable"},
		fieldname = "plycuring",
		arealoaded = 1,
		soakrate = function(pos)
			if minetest.find_node_near(pos,
				1, {"group:concrete_flow", "group:water"}) then
				return false
			end
			local found = nodecore.find_nodes_around(pos, "group:igniter", 1)
			return #found + 1
		end,
		soakcheck = function(data, pos, node)
			if data.total < 100 then
				nodecore.smokefx(pos, 1, data.rate)
				return
			end
			local pattdef, etchdef = getdefs(minetest.get_node(pos))
			if not (pattdef and etchdef) then return end
			local curename = modname .. ":" .. etchdef.name .. "_" .. pattdef.name
			if pattdef.blank then curename = etchdef.basename end
			nodecore.smokeburst(pos)
			nodecore.dynamic_shade_add(pos, 1)
			nodecore.set_loud(pos, {name = curename, param2 = node.param2})
			nodecore.witness(pos, "cure pliant concrete")
			return false
		end
	})
