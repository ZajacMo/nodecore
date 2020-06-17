-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_tool(modname .. ":stylus", {
		description = "Stone-Tipped Stylus",
		tool_wears_to = "nc_tree:stick",
		inventory_image = modname .. "_tool_stylus.png",
		groups = {
			flammable = 2
		},
		tool_capabilities = nodecore.toolcaps({
				scratchy = 3
			}),
		on_ignite = "nc_stonework:chip",
		sounds = nodecore.sounds("nc_terrain_stony")
	})

nodecore.register_craft({
		label = "assemble stylus",
		normal = {y = 1},
		nodes = {
			{match = "nc_stonework:chip", replace = "air"},
			{y = -1, match = "nc_tree:stick", replace = "air"},
		},
		items = {
			{y = -1, name = modname .. ":stylus"}
		}
	})

local function getdefs(node)
	local def = minetest.registered_items[node.name] or {}
	return def.pattern_def, def.etch_def
end

nodecore.register_craft({
		label = "stylus etch",
		action = "pummel",
		toolgroups = {scratchy = 1},
		nodes = {
			{
				match = {groups = {concrete_etchable = true}}
			}
		},
		after = function(pos)
			local pattdef, etchdef = getdefs(minetest.get_node(pos))
			if not (pattdef and etchdef) then return end
			local plyname = modname .. ":" .. etchdef.name .. "_"
			.. pattdef.next.name .. "_ply"
			nodecore.set_loud(pos, {name = plyname})
		end
	})

nodecore.register_soaking_abm({
		label = "pliable concrete cure",
		interval = 1,
		chance = 1,
		limited_max = 100,
		nodenames = {"group:concrete_etchable"},
		fieldname = "plycuring",
		soakrate = function(pos)
			if minetest.find_node_near(pos,
				1, {"group:concrete_flow", "group:water"}) then
				return false
			end
			local found = nodecore.find_nodes_around(pos, "group:igniter", 1)
			return #found + 1
		end,
		soakcheck = function(data, pos)
			if data.total < 100 then
				nodecore.smokefx(pos, 1, data.rate)
				return
			end
			local pattdef, etchdef = getdefs(minetest.get_node(pos))
			if not (pattdef and etchdef) then return end
			local curename = modname .. ":" .. etchdef.name .. "_" .. pattdef.name
			if pattdef.blank then curename = etchdef.basename end
			nodecore.set_loud(pos, {name = curename})
			return false
		end
	})
