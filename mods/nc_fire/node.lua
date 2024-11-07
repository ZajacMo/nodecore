-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc
    = core, ipairs, math, nc
local math_floor, math_sqrt
    = math.floor, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

-- "fire" is a flame node sustained by nearby fuel.
-- "fire_burst" is a small self-contained burst of flame from its
-- own internal fuel that goes out after a set time.
for _, name in ipairs({":fire", ":fire_burst"}) do
	core.register_node(modname .. name, {
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
						length = 0.6
					}
				}
			},
			paramtype = "light",
			light_source = 12,
			groups = {
				igniter = 1,
				flame = 1,
				stack_as_node = 1,
				damage_touch = 1,
				damage_radiant = 1,
				flame_ambiance = 1,
				cheat = 1
			},
			stack_max = 1,
			damage_per_second = 1,
			sunlight_propagates = true,
			floodable = true,
			walkable = false,
			touchthru = true,
			pointable = false,
			buildable_to = true,
			drop = "",
			mapcolor = {r = 244, g = 182, b = 94, a = 160},
		})
end

nc.register_dnt({
		name = modname .. ":fire_burst",
		nodenames = {modname .. ":fire_burst"},
		time = 2,
		autostart = true,
		action = function(pos)
			return core.remove_node(pos)
		end
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
		for i = 1, base do
			name = name .. "^" .. txr("coal_" .. i)
		end
	end
	local rem = (num / 2) - base
	if rem > 0 then
		name = name .. "^" .. txr("coal_" .. (base + 1), rem)
	end
	return name
end

local function rampcolor(r1, g1, b1, r2, g2, b2, q)
	return {
		r = r1 * (1 - q) + r2 * q,
		g = g1 * (1 - q) + g2 * q,
		b = b1 * (1 - q) + b2 * q,
	}
end

for num = 1, nc.fire_max do
	core.register_node(modname .. ":coal" .. num, {
			description = "Charcoal",
			tiles = {txrcoal(num) .. "^[noalpha"},
			groups = {
				crumbly = 1,
				flammable = 5 - math_floor(num / nc.fire_max * 4),
				falling_node = 1,
				fire_fuel = num,
				charcoal = num
			},
			crush_damage = 1,
			sounds = nc.sounds("nc_terrain_crunchy"),
			mapcolor = rampcolor(158, 158, 158, 32, 32, 32, num / nc.fire_max),
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

for num = 1, nc.fire_max do
	core.register_node(modname .. ":ember" .. num, {
			description = "Burning Embers",
			tiles = {txrember(num) .. "^[noalpha"},
			paramtype = "light",
			light_source = 6,
			groups = {
				igniter = 1,
				ember = num,
				falling_node = 1,
				stack_as_node = 1,
				damage_touch = 1,
				damage_radiant = 3,
				cheat = 1
			},
			stack_max = 1,
			drop = "",
			crush_damage = 1,
			sounds = nc.sounds("nc_terrain_crunchy"),
			mapcolor = rampcolor(158, 158, 158, 244, 182, 94, num / nc.fire_max),

		})
end
core.register_alias(modname .. ":fuel", modname .. ":ember2")

core.register_node(modname .. ":ash", {
		description = "Ash",
		tiles = {modname .. "_ash.png"},
		groups = {
			falling_node = 1,
			falling_repose = 1,
			crumbly = 1
		},
		crush_damage = 0.25,
		sounds = nc.sounds("nc_terrain_swishy"),
		visinv_bulk_optimize = true,
		mapcolor = {r = 158, g = 158, b = 158},
	})
