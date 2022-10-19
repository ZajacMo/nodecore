-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local txr_sides = "(nc_lode_annealed.png^[mask:nc_tote_sides.png)"
local txr_handle = "(nc_lode_annealed.png^nc_tote_knurl.png)"
local txr_top = txr_handle .. "^[transformFX^[mask:nc_tote_top.png^[transformR90^" .. txr_sides

local function reg(level)
	return minetest.register_node(modname .. ":lamp" .. level, {
			description = "Lux Lantern",
			drawtype = "mesh",
			visual_scale = nodecore.z_fight_ratio,
			mesh = "nc_tote_handle.obj",
			selection_box = nodecore.fixedbox(),
			paramtype = "light",
			paramtype2 = "facedir",
			tiles = {
				txr_sides,
				txr_sides,
				txr_top,
				txr_handle,
				"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:"
				.. (level * 36) .. ")"
			},
			backface_culling = true,
			use_texture_alpha = "clip",
			groups = {
				[modname] = level + 1,
				snappy = 1,
				lux_emit = level,
			},
			stack_max = 1,
			light_source = level * 2,
			sounds = nodecore.sounds("nc_lode_annealed"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				local meta = minetest.get_meta(pos)
				meta:from_table(itemstack:get_meta():to_table())
			end,
		})
end

for i = 0, 7 do reg(i) end

nodecore.register_craft({
		label = "assemble lantern",
		normal = {x = 1},
		indexkeys = {"nc_optics:glass_opaque"},
		nodes = {
			{match = "nc_optics:glass_opaque", replace = "air"},
			{x = -1, match = "nc_tote:handle", replace = modname .. ":lamp0"},
		}
	})

nodecore.register_craft({
		label = "break apart lantern",
		action = "pummel",
		toolgroups = {choppy = 5},
		indexkeys = {"group:" .. modname},
		nodes = {
			{
				match = {groups = {[modname] = true}},
				replace = "air"
			}
		},
		items = {
			{name = "nc_lode:bar_annealed 2", count = 4, scatter = 5},
			{name = "nc_optics:glass_crude", scatter = 5}
		}
	})
