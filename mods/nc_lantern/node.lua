-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local txr_sides = "(nc_lode_annealed.png^[mask:nc_tote_sides.png)"
local txr_handle = "(nc_lode_annealed.png^nc_tote_knurl.png)"
local txr_top = txr_handle .. "^[transformFX^[mask:nc_tote_top.png^[transformR90^" .. txr_sides

local function reg(level)
	return minetest.register_node(modname .. ":lamp" .. level, {
			description = "Lantern",
			drawtype = "mesh",
			visual_scale = nodecore.z_fight_ratio,
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
