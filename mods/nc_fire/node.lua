-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor, math_sqrt
    = math.floor, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":fire", {
		description = "Fire",
		drawtype = "firelike",
		visual_scale = 1.5,
		tiles = {
			{
				name = "nc_fire_fire.png",
				animation = {
					["type"] = "vertical_frames",
					aspect_w = 24,
					aspect_h = 24,
					length = 4
				}
			}
		},
		paramtype = "light",
		light_source = 12,
		groups = {
			igniter = 1,
			flame = 1
		},
		damage_per_second = 2,
		sunlight_propagates = true,
		floodable = true,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		drop = ""
	})

local function txr(name, opaq)
	local full = modname .. "_" .. name .. ".png"
	if opaq and opaq < 1 then
		full = "(" .. full .. "^[opacity:"
		.. math_floor(256 * math_sqrt(opaq)) .. ")"
	end
	return full
end

local function txrcoal(num)
	local name = txr("ash")
	local base = math_floor(num / 2)
	if base > 0 then
		for i = base, 1, -1 do
			name = name .. "^" .. txr("coal_" .. i)
		end
	end
	local rem = (num / 2) - base
	if rem > 0 then
		name = name .. "^" .. txr("coal_" .. (base + 1), rem)
	end
	return name
end

for num = 1, nodecore.fire_max do
	minetest.register_node(modname .. ":coal" .. num, {
			description = "Charcoal",
			tiles = {txrcoal(num) .. "^[noalpha"},
			groups = {
				crumbly = 1,
				flammable = 5 - math_floor(num / nodecore.fire_max * 4),
				falling_node = 1,
				fire_fuel = num,
				charcoal = num
			},
			crush_damage = 1,
			sounds = nodecore.sounds("nc_terrain_crunchy")
		})
end

local function txrember(num)
	local name = txrcoal(num)
	local base = math_floor(num / 2)
	if base > 0 then
		name = name .. "^" .. txr("ember_" .. base)
	end
	local rem = (num / 2) - base
	if rem > 0 then
		name = name .. "^" .. txr("ember_" .. (base + 1), rem)
	end
	return name
end

for num = 1, nodecore.fire_max do
	minetest.register_node(modname .. ":ember" .. num, {
			description = "Burning Embers",
			tiles = {txrember(num) .. "^[noalpha"},
			paramtype = "light",
			light_source = 6,
			groups = {
				igniter = 1,
				ember = num,
				falling_node = 1
			},
			drop = "",
			diggable = false,
			damage_per_second = 2,
			on_punch = nodecore.node_punch_hurt,
			crush_damage = 1,
			sounds = nodecore.sounds("nc_terrain_crunchy")
		})
end
minetest.register_alias(modname .. ":fuel", modname .. ":ember2")

minetest.register_node(modname .. ":ash", {
		description = "Ash",
		tiles = {modname .. "_ash.png"},
		groups = {
			falling_node = 1,
			falling_repose = 1,
			crumbly = 1
		},
		crush_damage = 0.25,
		sounds = nodecore.sounds("nc_terrain_swishy")
	})
