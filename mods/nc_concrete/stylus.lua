-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, pairs
    = ItemStack, core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_tool(modname .. ":stylus", {
		description = "Stone-Tipped Stylus",
		tool_wears_to = "nc_tree:stick",
		inventory_image = modname .. "_tool_stylus.png",
		groups = {
			flammable = 2,
			nc_doors_pummel_first = 1
		},
		tool_capabilities = nc.toolcaps({
				scratchy = 3
			}),
		on_ignite = "nc_stonework:chip",
		sounds = nc.sounds("nc_terrain_stony"),
		on_stack_touchtip = function(stack, desc)
			local patt = stack:get_meta():get_string("pattern")
			if not patt then return desc end
			for _, def in pairs(nc.registered_concrete_patterns) do
				if patt == def.name and def.description then
					return desc .. "\n" .. def.description
				end
			end
			return desc
		end
	})

nc.register_craft({
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
				nc.pickrand(nc.registered_concrete_patterns).name)
			return nc.item_eject(pos, item)
		end
	})

local function getdefs(node)
	local def = core.registered_items[node.name] or {}
	return def.pattern_def, def.etch_def
end

local function setply(pos, nodename, player)
	local node = {name = nodename}
	if core.registered_nodes[node.name].paramtype2 == "4dir"
	and player then
		node.param2 = core.dir_to_fourdir(
			player:get_look_dir())
	end
	nc.set_loud(pos, node)
end
nc.register_craft({
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
			local pattdef, etchdef = getdefs(core.get_node(pos))
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
				nc.player_discover(data.crafter, "stylus train")
				data.crafter:set_wielded_item(data.wield)
			elseif data.presstoolpos then
				nc.witness(pos, "stylus train")
				nc.stack_set(data.presstoolpos, wield)
			end
		end
	})

nc.register_soaking_abm({
		label = "pliable concrete cure",
		interval = 1,
		nodenames = {"group:concrete_etchable"},
		fieldname = "plycuring",
		arealoaded = 1,
		soakrate = function(pos)
			if core.find_node_near(pos,
				1, {"group:concrete_flow", "group:water"}) then
				return false
			end
			local found = nc.find_nodes_around(pos, "group:igniter", 1)
			return #found + 1
		end,
		soakcheck = function(data, pos, node)
			if data.total < 100 then
				nc.smokefx(pos, 1, data.rate)
				return
			end
			local pattdef, etchdef = getdefs(core.get_node(pos))
			if not (pattdef and etchdef) then return end
			local curename = modname .. ":" .. etchdef.name .. "_" .. pattdef.name
			if pattdef.blank then curename = etchdef.basename end
			nc.smokeburst(pos)
			nc.dynamic_shade_add(pos, 1)
			nc.set_loud(pos, {name = curename, param2 = node.param2})
			nc.witness(pos, "cure pliant concrete")
			return false
		end
	})
