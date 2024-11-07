-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, vector
    = core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local wetdef = {
	description = "Flux",
	tiles = {modname .. "_base.png^[opacity:64"},
	special_tiles = {modname .. "_base.png^[opacity:64", modname .. "_base.png^[opacity:64"},
	use_texture_alpha = "blend",
	paramtype = "light",
	liquid_viscosity = 0,
	liquid_move_physics = false,
	liquid_renewable = false,
	liquid_range = 2,
	liquid_alternative_flowing = modname .. ":flux_flowing",
	liquid_alternative_source = modname .. ":flux_source",
	pointable = false,
	walkable = false,
	buildable_to = true,
	light_source = 10,
	sunlight_propagates = true,
	air_pass = true,
	drowning = 0,
	groups = {
		lux_emit = 16,
		lux_fluid = 1
	},
	post_effect_color = {a = 64, r = 251, g = 241, b = 143},
}
core.register_node(modname .. ":flux_source", nc.underride({
			drawtype = "liquid",
			liquidtype = "source"
		}, wetdef))
core.register_node(modname .. ":flux_flowing", nc.underride({
			drawtype = "flowingliquid",
			liquidtype = "flowing",
			paramtype2 = "flowingliquid"
		}, wetdef))

local outdirs = {}
for _, v in pairs(nc.dirs()) do
	if v.y <= 0 then
		outdirs[#outdirs + 1] = v
	end
end
core.register_abm({
		label = "lux flow leak",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_cobble_max"},
		action = function(pos)
			for _, v in pairs(outdirs) do
				local p = vector.add(pos, v)
				if nc.buildable_to(p) then
					nc.set_node_check(p, {name = modname .. ":flux_source"})
				end
			end
		end
	})

local indirs = {}
for _, v in pairs(nc.dirs()) do
	if v.y >= 0 then
		indirs[#indirs + 1] = v
	end
end
core.register_abm({
		label = "lux flow ebb",
		interval = 1,
		chance = 2,
		nodenames = {modname .. ":flux_source"},
		arealoaded = 1,
		action = function(pos)
			for _, v in pairs(indirs) do
				local p = vector.add(pos, v)
				local def = core.registered_nodes[core.get_node(p).name]
				if def and def.groups and def.groups.lux_cobble_max then return end
			end
			return core.set_node(pos, {name = modname .. ":flux_flowing", param2 = 7})
		end
	})
