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
				[modname] = level,
				snappy = 1,
				lux_emit = level,
			},
			stack_max = 1,
			light_source = level * 2,
			sounds = nodecore.sounds("nc_lode_annealed")
		})
end

for i = 0, 7 do reg(i) end
