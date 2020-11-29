-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_concrete(def)
	def = nodecore.underride(def, {
			name = def.description:lower():gsub("%W", "_"),
			groups_powder = {
				falling_node = 1,
				falling_repose = 1,
				concrete_powder = 1
			},
			groups_wet = {concrete_wet = 1},
			swim_color = {a = 240, r = 32, g = 32, b = 32}
		})
	local basename = modname .. ":" .. def.name
	def.basename = basename

	if def.register_dry ~= false then
		minetest.register_node(":" .. basename, {
				description = def.description,
				tiles = {def.tile_powder},
				groups = def.groups_powder,
				crush_damage = 1,
				sounds = nodecore.sounds(def.sound),
				concrete_def = def
			})
	end

	if def.register_wet ~= false then
		local wetdef = {
			description = "Wet " .. def.description,
			tiles = {def.tile_wet},
			special_tiles = {def.tile_wet, def.tile_wet},
			paramtype = "light",
			liquid_viscosity = 15,
			liquid_renewable = false,
			liquid_range = 1,
			liquid_alternative_flowing = basename .. "_wet_flowing",
			liquid_alternative_source = basename .. "_wet_source",
			walkable = false,
			drowning = 2,
			post_effect_color = def.swim_color,
			groups = def.groups_wet,
			sounds = nodecore.sounds(def.sound),
			concrete_def = def
		}
		minetest.register_node(":" .. basename .. "_wet_source", nodecore.underride({
					liquidtype = "source",
					groups = {concrete_source = 1}
				}, wetdef))
		minetest.register_node(basename .. "_wet_flowing", nodecore.underride({
					drawtype = "flowingliquid",
					liquidtype = "flowing",
					paramtype2 = "flowingliquid",
					groups = {concrete_flow = 1}
				}, wetdef))
	end

	if def.craft_mix ~= false then
		nodecore.register_craft({
				label = "mix " .. def.name .. " (fail)",
				action = "pummel",
				priority = 2,
				toolgroups = {thumpy = 1},
				normal = {y = 1},
				indexkeys = def.craft_from_keys,
				nodes = {
					{
						match = def.craft_from
					},
					{
						x = 1,
						y = -1,
						match = {buildable_to = true}
					},
					{
						y = -1,
						match = "nc_fire:ash",
						replace = "air"
					}
				},
				before = function(pos)
					nodecore.item_disperse(pos, "nc_fire:lump_ash", 8)
				end
			})
		nodecore.register_craft({
				label = "mix " .. def.name,
				action = "pummel",
				priority = 1,
				toolgroups = {thumpy = 1},
				normal = {y = 1},
				indexkeys = def.craft_from_keys,
				nodes = {
					{
						match = def.craft_from,
						replace = "air"
					},
					{
						y = -1,
						match = "nc_fire:ash",
						replace = basename
					}
				}
			})
	end
end
