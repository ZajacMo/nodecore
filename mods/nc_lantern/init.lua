-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_ceil, math_floor
    = math.ceil, math.floor
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
				lux_emit = math_ceil(level / 2),
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

local charge_per_level = 1000
local discharge_rate = 20

local function soakrate(pos, node)
	local wet
	if node then
		wet = nodecore.quenched(pos)
	else
		wet = minetest.get_item_group(node or minetest.get_node(pos), "moist") > 0
	end
	return (nodecore.lux_soak_rate(pos) or 0) - discharge_rate * (wet and 3 or 1)
end
local function soakgetname(data)
	if data.total < 0 then data.total = 0 end
	if data.total >= charge_per_level * 8 then data.total = charge_per_level * 8 - 1 end
	return modname .. ":lamp" .. math_floor(data.total / charge_per_level)
end

nodecore.register_soaking_abm({
		label = "lantern charge",
		fieldname = "charge",
		interval = 10,
		arealoaded = 14,
		nodenames = {"group:" .. modname},
		soakrate = soakrate,
		soakcheck = function(data, pos, node)
			local newname = soakgetname(data)
			if node.name == newname then return end
			node.name = newname
			nodecore.set_node(pos, node)
		end
	})
nodecore.register_soaking_aism({
		label = "lantern charge",
		fieldname = "charge",
		interval = 10,
		arealoaded = 14,
		itemnames = "group:" .. modname,
		soakrate = function(_, aismdata)
			local pos = aismdata.pos or aismdata.player and aismdata.player:get_pos()
			return soakrate(pos)
		end,
		soakcheck = function(data, stack)
			stack:set_name(soakgetname(data))
			return data.total, stack
		end
	})
