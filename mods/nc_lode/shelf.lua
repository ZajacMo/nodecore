-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

core.register_node(modname .. ":form", {
		description = "Lode Form",
		tiles = {modname .. "_annealed.png^[mask:nc_api_storebox_frame.png"},
		selection_box = nc.fixedbox(),
		collision_box = nc.fixedbox(),
		groups = {
			cracky = 2,
			totable = 1,
			storebox = 2,
			visinv = 1,
			metallic = 1,
			lode_cube = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nc.sounds("nc_lode_annealed"),
		storebox_access = function() return true end,
		mapcolor = {r = 47, g = 36, b = 32, a = 64},
	})

local function regconv(from, to)
	return nc.register_craft({
			label = "lode " .. from .. " to " .. to,
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":" .. from},
			check = function(pos)
				return nc.stack_get(pos):is_empty()
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

local function cbox(s) return nc.fixedbox(-s, -s, -s, s, s, s) end
core.register_node(modname .. ":shelf", {
		description = "Lode Crate",
		collision_box = cbox(0.5),
		selection_box = cbox(0.5),
		tiles = {tile("side"), tile("base"), tile("side")},
		groups = {
			cracky = 3,
			visinv = 1,
			storebox = 2,
			totable = 1,
			metallic = 1,
			lode_cube = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nc.sounds("nc_lode_annealed"),
		storebox_access = function(pt) return pt.above.y >= pt.under.y end,
		mapcolor = {r = 47, g = 36, b = 32, a = 192},
	})

nc.register_craft({
		label = "assemble lode shelf",
		action = "stackapply",
		indexkeys = {modname .. ":form"},
		wield = {name = modname .. ":bar_annealed"},
		consumewield = 1,
		nodes = {
			{
				match = {name = modname .. ":form", empty = true},
				replace = modname .. ":shelf"
			},
		}
	})

nc.register_craft({
		label = "break apart lode shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {choppy = 3},
		check = function(pos) return nc.stack_get(pos):is_empty() end,
		indexkeys = {modname .. ":shelf"},
		nodes = {
			{
				match = {name = modname .. ":shelf", empty = true},
				replace = "air"
			},
		},
		items = {
			{name = modname .. ":frame_annealed", scatter = 0.001},
			{name = modname .. ":bar_annealed", scatter = 0.001}
		}
	})
