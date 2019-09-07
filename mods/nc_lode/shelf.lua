-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function tile(n)
	return {
		name = modname .. "_annealed.png^[mask:" .. modname .. "_shelf_" .. n .. ".png",
		backface_culling = false
	}
end

local function cbox(s) return nodecore.fixedbox(-s, -s, -s, s, s, s) end
minetest.register_node(modname .. ":shelf", {
		description = "Lode Crate",
		drawtype = "nodebox",
		node_box = cbox(127/256),
		collision_box = cbox(0.5),
		selection_box = cbox(0.5),
		tiles = {tile("side"), tile("base"), tile("side")},
		groups = {
			cracky = 3,
			visinv = 1,
			container = 1,
			totable = 1
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_lode_annealed"),
		on_construct = function(pos)
			local inv = minetest.get_meta(pos):get_inventory()
			inv:set_size("solo", 1)
			nodecore.visinv_update_ents(pos)
		end,
		on_rightclick = function(pos, _, clicker, stack, pointed_thing)
			if not nodecore.interact(clicker) then return end
			if pointed_thing.above.y < pointed_thing.under.y then return end
			if not stack or stack:is_empty() then return end
			local def = minetest.registered_items[stack:get_name()] or {}
			if def.groups and def.groups.visinv then
				return minetest.item_place_node(stack, clicker, pointed_thing)
			end
			return nodecore.stack_add(pos, stack)
		end,
		on_punch = function(pos, node, puncher, pointed_thing, ...)
			minetest.node_punch(pos, node, puncher, pointed_thing, ...)
			if not nodecore.interact(puncher) then return end
			if pointed_thing.above.y < pointed_thing.under.y then return end
			return nodecore.stack_giveto(pos, puncher)
		end,
		on_dig = function(pos, node, digger, ...)
			if nodecore.stack_giveto(pos, digger) then
				return minetest.node_dig(pos, node, digger, ...)
			end
		end,
		stack_allow = function(_, _, stack)
			local def = minetest.registered_items[stack:get_name()] or {}
			if def.groups and def.groups.container then return false end
		end
	})

nodecore.register_craft({
		label = "assemble lode shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {thumpy = 3},
		nodes = {
			{match = modname .. ":prill_hot", replace = "air"},
			{x = -1, z = -1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 1, z = -1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = -1, z = 1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 1, z = 1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
		},
		items = {
			modname .. ":prill_annealed"
		}
	})

nodecore.register_craft({
		label = "assemble lode shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {thumpy = 3},
		nodes = {
			{match = modname .. ":prill_hot", replace = "air"},
			{x = -1, z = 0, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 1, z = 0, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 0, z = -1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 0, z = 1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
		},
		items = {
			modname .. ":prill_annealed"
		}
	})

nodecore.register_craft({
		label = "break apart lode shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {choppy = 3},
		check = function(pos) return nodecore.stack_get(pos):is_empty() end,
		nodes = {
			{match = modname .. ":shelf", replace = "air"},
		},
		items = {
			{name = modname .. ":bar_annealed 2", scatter = 0.001}
		}
	})
