-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function tile(n)
	return modname .. "_annealed.png^[mask:" .. modname .. "_shelf_" .. n .. ".png"
end

local function cbox(s) return nodecore.fixedbox(-s, -s, -s, s, s, s) end
minetest.register_node(modname .. ":shelf", {
		description = "Lode Crate",
		collision_box = cbox(0.5),
		selection_box = cbox(0.5),
		tiles = {tile("side"), tile("base"), tile("side")},
		use_texture_alpha = true,
		groups = {
			cracky = 3,
			visinv = 1,
			storebox = 2,
			totable = 1,
			metal_cube = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_lode_annealed"),
		storebox_access = function(pt) return pt.above.y >= pt.under.y end
	})

nodecore.register_craft({
		label = "assemble lode shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {thumpy = 3},
		indexkeys = {modname .. ":prill_hot"},
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
		indexkeys = {modname .. ":prill_hot"},
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
		indexkeys = {modname .. ":shelf"},
		nodes = {
			{match = modname .. ":shelf", replace = "air"},
		},
		items = {
			{name = modname .. ":bar_annealed 2", scatter = 0.001}
		}
	})
