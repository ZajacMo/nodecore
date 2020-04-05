-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_concrete(def)
	def = nodecore.underride(def, {
			name = def.description:lower():gsub("%W", "_"),
			groups_powder = {falling_node = 1, falling_repose = 1},
			groups_wet = {concrete_wet = 1},
			swim_color = {a = 240, r = 32, g = 32, b = 32}
		})
	local basename = modname .. ":" .. def.name

	if def.register_dry ~= false then
		minetest.register_node(basename, {
				description = def.description,
				tiles = {def.tile_powder},
				groups = def.groups_powder,
				crush_damage = 1,
				sounds = nodecore.sounds(def.sound)
			})
	end

	if def.register_wet ~= false then
		local wetdef = {
			description = "Wet " .. def.description,
			tiles = {def.tile_wet},
			special_tiles = {def.tile_wet, def.tile_wet},
			liquid_viscosity = 15,
			liquid_renewable = false,
			liquid_range = 1,
			liquid_alternative_flowing = basename .. "_wet_flowing",
			liquid_alternative_source = basename .. "_wet_source",
			walkable = false,
			diggable = false,
			drowning = 2,
			post_effect_color = def.swim_color,
			groups = def.groups_wet,
			sounds = nodecore.sounds(def.sound)
		}
		minetest.register_node(basename .. "_wet_source", nodecore.underride({
					liquidtype = "source"
				}, wetdef))
		minetest.register_node(basename .. "_wet_flowing", nodecore.underride({
					drawtype = "flowingliquid",
					liquidtype = "flowing",
					paramtype2 = "flowingliquid"
				}, wetdef))
	end
end
