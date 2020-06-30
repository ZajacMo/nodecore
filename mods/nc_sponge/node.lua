-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
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
		sounds = nodecore.sounds("nc_terrain_swishy")
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
		sounds = nodecore.sounds("nc_terrain_swishy")
	})

local function esc(t) return t:gsub("%^", "\\^"):gsub(":", "\\:") end
local base = modname .. ".png^[resize:16x16"
local liv = modname .. "_living.png^[resize:16x16"
local water = "nc_terrain_water.png"
local h = 32
local txr = "[combine:16x" .. (16 * h)
for i = 0, h - 1 do
	txr = txr .. ":0," .. (16 * i) .. "=" .. esc(
		base .. "^(" .. liv .. "^[mask:" .. modname .. "_mask1.png^[opacity:"
		.. math_ceil(math_cos(i * math_pi * 2 / h) * 63 + 192)
		.. ")^(" .. liv .. "^[mask:" .. modname .. "_mask2.png^[opacity:"
		.. math_ceil(-math_cos(i * math_pi * 2 / h) * 63 + 192)
		.. ")^(" .. water .. "^[opacity:96)")
end
print(txr)

minetest.register_node(modname .. ":sponge_living", {
		description = "Living Sponge",
		drawtype = "allfaces_optional",
		tiles = {
			{
				name = txr,
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
		sounds = nodecore.sounds("nc_terrain_swishy")
	})
