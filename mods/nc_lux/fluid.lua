-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local wetdef = {
	description = "Lux Flow",
	tiles = {modname .. "_base.png"},
	special_tiles = {modname .. "_base.png", modname .. "_base.png"},
	alpha = 64,
	liquid_viscosity = 0,
	liquid_renewable = false,
	liquid_range = 2,
	liquid_alternative_flowing = modname .. ":flux_flowing",
	liquid_alternative_source = modname .. ":flux_source",
	pointable = false,
	walkable = false,
	diggable = false,
	buildable_to = true,
	light_source = 10,
	damage_per_second = 1,
	drowning = 0,
	groups = {lux_emit = 10, lux_fluid = 1, stack_as_node = 1},
	post_effect_color = {a = 64, r = 251, g = 241, b = 143},
	sounds = nodecore.sounds("nc_terrain_chompy")
}
minetest.register_node(modname .. ":flux_source", nodecore.underride({
			drawtype = "liquid",
			liquidtype = "source"
		}, wetdef))
minetest.register_node(modname .. ":flux_flowing", nodecore.underride({
			drawtype = "flowingliquid",
			liquidtype = "flowing",
			paramtype2 = "flowingliquid"
		}, wetdef))

local outdirs = {}
for _, v in pairs(nodecore.dirs()) do
	if v.y <= 0 then
		outdirs[#outdirs + 1] = v
	end
end
nodecore.register_limited_abm({
		label = "Lux Flow Leakage",
		interval = 1,
		chance = 2,
		limited_max = 100,
		nodenames = {"group:lux_cobble_max"},
		action = function(pos)
			for _, v in pairs(outdirs) do
				local p = vector.add(pos, v)
				if minetest.get_node(p).name ~= modname .. ":flux_source"
				and nodecore.buildable_to(p) then
					minetest.set_node(p, {name = modname .. ":flux_source"})
				end
			end
		end
	})

local indirs = {}
for _, v in pairs(nodecore.dirs()) do
	if v.y >= 0 then
		indirs[#indirs + 1] = v
	end
end
nodecore.register_limited_abm({
		label = "Lux Flow Ebb",
		interval = 1,
		chance = 2,
		limited_max = 100,
		nodenames = {modname .. ":flux_source"},
		action = function(pos)
			for _, v in pairs(indirs) do
				local p = vector.add(pos, v)
				local def = minetest.registered_nodes[minetest.get_node(p).name]
				if def and def.groups and def.groups.lux_cobble_max then return end
			end
			minetest.remove_node(pos)
		end
	})
