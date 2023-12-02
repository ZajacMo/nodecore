-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, tostring
    = math, minetest, nodecore, tostring
local math_ceil, math_cos, math_pi
    = math.ceil, math.cos, math.pi
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":sponge", {
		description = "Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname .. ".png"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			flammable = 3,
			fire_fuel = 3,
			sponge = 1
		},
		air_pass = true,
		sounds = nodecore.sounds("nc_terrain_swishy"),
		mapcolor = {r = 194, g = 182, b = 0},
	})

minetest.register_node(modname .. ":sponge_wet", {
		description = "Wet Sponge",
		drawtype = "allfaces_optional",
		tiles = {modname .. ".png^(nc_terrain_water.png^[opacity:96)"},
		paramtype = "light",
		groups = {
			crumbly = 2,
			coolant = 1,
			falling_node = 1,
			moist = 1,
			sponge = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy"),
		mapcolor = {r = 142, g = 133, b = 188},
	})

local base = (nodecore.tmod(modname .. ".png")
	:resize(16, 16))
local liv1 = (nodecore.tmod(modname .. "_living.png")
	:resize(16, 16)
	:mask(modname .. "_mask1.png"))
local liv2 = (nodecore.tmod(modname .. "_living.png")
	:resize(16, 16)
	:mask(nodecore.tmod(modname .. "_mask1.png")
		:invert("a")))
local water = (nodecore.tmod("nc_terrain_water.png")
	:opacity(96))
local h = 32
local txr = nodecore.tmod:combine(16, h * 16)
for i = 0, h - 1 do
	local a1 = math_ceil(math_cos(i * math_pi * 2 / h) * 63 + 192)
	local a2 = math_ceil(-math_cos(i * math_pi * 2 / h) * 63 + 192)
	txr = txr:layer(0, 16 * i, base
		:add(liv1:opacity(a1))
		:add(liv2:opacity(a2))
		:add(water))
end

minetest.register_node(modname .. ":sponge_living", {
		description = "Living Sponge",
		drawtype = "allfaces_optional",
		tiles = {
			{
				name = tostring(txr),
				animation = {
					["type"] = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 2
				}
			}
		},
		paramtype = "light",
		groups = {
			crumbly = 2,
			coolant = 1,
			moist = 1,
			sponge = 1
		},
		sounds = nodecore.sounds("nc_terrain_swishy"),
		mapcolor = {r = 142, g = 133, b = 188},
	})
