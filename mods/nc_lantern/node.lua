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
			mesh = "nc_tote_handle.obj",
			paramtype = "light",
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
			},
			node_placement_prediction = "nc_items:stack",
			place_as_item = true,
			stack_max = 1,
			light_source = level * 2,
			sounds = nodecore.sounds("nc_lode_annealed")
		})
end

for i = 0, 7 do reg(i) end
