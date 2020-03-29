-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor, math_pow
    = math.floor, math.pow
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

for i = 1, 8 do
	minetest.register_node(modname .. ":cobble" .. i, {
			description = "Lux Cobble",
			tiles = {
				"nc_terrain_gravel.png^((" .. modname .. "_base.png^[mask:"
				.. modname .. "_dot_mask.png)^[opacity:"
				.. (i * 32) .. ")^nc_terrain_cobble.png"
			},
			stackfamily = modname .. ":cobble",
			groups = {
				lux_cobble = 1,
				lux_emit = i,
				cracky = 1,
				cobbley = 1,
				lux_cobble_max = i == 8 and 1 or nil,
				igniter = i > 4 and 1 or nil,
				lux_hot = i > 4 and 1 or nil
			},
			alternate_loose = {
				stackfamily = modname .. ":cobble_loose",
				repack_level = 2,
				groups = {
					cracky = 0,
					crumbly = 2,
					falling_repose = 3,
				},
				drop = modname .. ":cobble1_loose",
				sounds = nodecore.sounds("nc_terrain_chompy")
			},
			crush_damage = 2,
			sounds = nodecore.sounds("nc_terrain_stony"),
			light_source = i + 1
		})
end

local strata = {}
minetest.register_node(modname .. ":stone", {
		description = "Stone",
		tiles = {"nc_terrain_stone.png"},
		strata = strata,
		groups = {
			lux_emit = 1,
			cracky = 2
		},
		light_source = 1,
		drop_in_place = modname .. ":cobble1",
		sounds = nodecore.sounds("nc_terrain_stony")
	})
strata[1] = modname .. ":stone"

for i = 1, nodecore.hard_stone_strata do
	local n = modname .. ":stone_" .. i
	strata[i + 1] = n
	minetest.register_node(n, {
			description = "Stone",
			tiles = {nodecore.hard_stone_tile(i)},
			groups = {
				lux_emit = 1,
				cracky = i + 2,
				hard_stone = i
			},
			light_source = 1,
			drop_in_place = modname .. ((i > 1)
				and (":stone_" .. (i - 1)) or ":stone"),
			sounds = nodecore.sounds("nc_terrain_stony")
		})
end

local oreid = 0
local function regore(def)
	oreid = oreid + 1
	return minetest.register_ore(nodecore.underride(def, {
				name = modname .. oreid,
				ore_type = "scatter",
				ore = modname .. ":stone",
				wherein = "nc_terrain:stone",
				clust_num_ores = 3,
				clust_size = 2,
				random_factor = 0,
				noise_params = {
					offset = 0,
					scale = 4,
					spread = {x = 40, y = 5, z = 40},
					seed = 5672,
					octaves = 3,
					persist = 0.5,
					flags = "eased",
				},
				noise_threshold = 1.2
			}, def))
end
for y = 0, 7 do
	local def = {
		y_max = 32 - 48 * math_pow(2, y),
		y_min = 32 - 48 * math_pow(2, y + 1),
		clust_scarcity = math_floor(8 * 8 * 8 * 8 * math_pow(0.67, y)),
	}
	if y == 7 then def.y_min = nil end
	regore(def)
end
