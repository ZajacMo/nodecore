-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local txr_sides = "(nc_lode_annealed.png^[mask:nc_tote_sides.png)"
local txr_handle = "(nc_lode_annealed.png^nc_tote_knurl.png)"
local txr_top = txr_handle .. "^[transformFX^[mask:nc_tote_top.png^[transformR90^" .. txr_sides

local function rampcolor(r1, g1, b1, r2, g2, b2, q)
	return {
		r = r1 * (1 - q) + r2 * q,
		g = g1 * (1 - q) + g2 * q,
		b = b1 * (1 - q) + b2 * q,
	}
end

local function reg(level)
	return core.register_node(modname .. ":lamp" .. level, {
			description = "Lantern",
			drawtype = "mesh",
			visual_scale = nc.z_fight_ratio,
			mesh = "nc_tote_handle.obj",
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
				[modname .. "_charged"] = level > 0 and level or nil,
				[modname .. "_full"] = level == 7 and 1 or nil,
				snappy = 1,
				lux_emit = math_ceil(level / 2),
				stack_as_node = 1,
				falling_node = 1,
				falling_mapgen_ignore = 1,
			},
			stack_max = 1,
			light_source = level * 2,
			sounds = nc.sounds("nc_lode_annealed"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				local meta = core.get_meta(pos)
				meta:from_table(itemstack:get_meta():to_table())
			end,
			mapcolor = rampcolor(162, 202, 222, 242, 236, 172, level / 7)
		})
end

for i = 0, 7 do reg(i) end
