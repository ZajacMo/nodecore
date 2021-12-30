-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":form", {
		description = "Lode Form",
		tiles = {modname .. "_annealed.png^[mask:nc_api_storebox_frame.png"},
		selection_box = nodecore.fixedbox(),
		collision_box = nodecore.fixedbox(),
		groups = {
			cracky = 2,
			totable = 1,
			storebox = 2,
			visinv = 1,
			lode_cube = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_lode_annealed"),
		storebox_access = function() return true end
	})

local function regconv(from, to)
	return nodecore.register_craft({
			label = "lode " .. from .. " to " .. to,
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":" .. from},
			check = function(pos)
				return nodecore.stack_get(pos):is_empty()
			end,
			nodes = {
				{
					match = modname .. ":" .. from,
					replace = modname .. ":" .. to
				},
				{
					y = -1,
					match = modname .. ":block_tempered"
				}
			}
		})
end
regconv("frame_annealed", "form")
regconv("form", "frame_annealed")

local function tile(n)
	return modname .. "_annealed.png^[mask:" .. modname .. "_shelf_" .. n .. ".png"
end

local function cbox(s) return nodecore.fixedbox(-s, -s, -s, s, s, s) end
minetest.register_node(modname .. ":shelf", {
		description = "Lode Crate",
		collision_box = cbox(0.5),
		selection_box = cbox(0.5),
		tiles = {tile("side"), tile("base"), tile("side")},
		groups = {
			cracky = 3,
			visinv = 1,
			storebox = 2,
			totable = 1,
			lode_cube = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_lode_annealed"),
		storebox_access = function(pt) return pt.above.y >= pt.under.y end
	})

nodecore.register_craft({
		label = "assemble lode shelf",
		action = "stackapply",
		indexkeys = {modname .. ":form"},
		wield = {name = modname .. ":bar_annealed"},
		consumewield = 1,
		nodes = {
			{match = modname .. ":form", replace = modname .. ":shelf"},
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
			{name = modname .. ":frame_annealed", scatter = 0.001},
			{name = modname .. ":bar_annealed", scatter = 0.001}
		}
	})
