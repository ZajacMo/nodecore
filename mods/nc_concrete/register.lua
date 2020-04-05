-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local localpref = modname .. ":" .. modname:gsub("^nc_", "") .. "_"

nodecore.register_concrete_etchable({
		basename = "nc_terrain:stone",
		pliant = {
			sounds = nodecore.sounds("nc_terrain_chompy"),
			drop_in_place = modname .. ":aggregate_wet_source",
			silktouch = false
		}
	})
nodecore.register_concrete({
		description = "Aggregate",
		tile_powder = "nc_terrain_gravel.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)",
		tile_wet = "nc_terrain_stone.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
		sound = "nc_terrain_chompy",
		groups_powder = {crumbly = 2},
		craft_from = {groups = {gravel = true}},
		to_crude = "nc_terrain:cobble",
		to_washed = "nc_terrain:gravel",
		to_molded = modname .. ":terrain_stone_blank_ply"
	})
minetest.register_alias(modname .. ":wet_source", modname .. ":aggregate_wet_source")
minetest.register_alias(modname .. ":wet_flowing", modname .. ":aggregate_wet_flowing")

nodecore.register_concrete_etchable({
		basename = modname .. ":sandstone",
		pliant_opacity = 40,
		pattern_opacity = 80,
		pliant = {
			sounds = nodecore.sounds("nc_terrain_crunchy"),
			drop_in_place = modname .. ":render_wet_source",
			silktouch = false
		}
	})
nodecore.register_concrete({
		description = "Render",
		tile_powder = "nc_terrain_sand.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)",
		tile_wet = "nc_terrain_sand.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
		sound = "nc_terrain_swishy",
		groups_powder = {crumbly = 1},
		swim_color = {r = 103, g = 103, b = 65},
		craft_from = {groups = {sand = true}},
		to_crude = "nc_terrain:sand",
		to_washed = "nc_terrain:sand",
		to_molded = localpref .. "sandstone_blank_ply"
	})

nodecore.register_concrete_etchable({
		basename = modname .. ":adobe",
		pattern_opacity = 56,
		pliant = {
			sounds = nodecore.sounds("nc_terrain_crunchy"),
			drop_in_place = modname .. ":mud_wet_source",
			silktouch = false
		}
	})
nodecore.register_concrete({
		name = "mud",
		description = "Adobe Mix",
		tile_powder = "nc_terrain_dirt.png^(nc_fire_ash.png^[mask:nc_concrete_mask.png)",
		tile_wet = "nc_terrain_dirt.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)",
		sound = "nc_terrain_crunchy",
		groups_powder = {crumbly = 1},
		swim_color = {r = 103, g = 103, b = 65},
		craft_from = {groups = {dirt = true}},
		to_crude = "nc_terrain:dirt",
		to_washed = "nc_terrain:dirt",
		to_molded = localpref .. "adobe_blank_ply"
	})

nodecore.register_concrete_etchable({
		basename = modname .. ":coalstone",
		pattern_opacity = 40,
		pliant_opacity = 128,
		pliant = {
			sounds = nodecore.sounds("nc_terrain_chompy"),
			drop_in_place = modname .. ":coalaggregate_wet_source",
			silktouch = false,
			drop = ""
		}
	})
nodecore.register_concrete({
		name = "coalaggregate",
		description = "Tarry Aggregate",
		register_dry = false,
		craft_mix = false,
		tile_wet = "nc_terrain_stone.png^(nc_fire_ash.png^("
		.. "nc_terrain_gravel.png^[opacity:128)^[mask:nc_concrete_mask.png)"
		.. "^[colorize:#000000:160",
		sound = "nc_terrain_chompy",
		swim_color = {r = 16, g = 16, b = 16},
		to_crude = "nc_terrain:cobble",
		to_washed = "nc_terrain:gravel",
		to_molded = localpref .. "coalstone_blank_ply"
	})
do
	local aggwet = modname .. ":aggregate_wet_source"
	local oldrc = nodecore.registered_nodes[aggwet].on_rightclick
	minetest.override_item(aggwet, {
			on_rightclick = function(pos, node, clicker, stack, ...)
				if stack:get_name() ~= "nc_fire:lump_coal" then
					return oldrc(pos, node, clicker, stack, ...)
				end
				nodecore.set_loud(pos,
					{name = modname .. ":coalaggregate_wet_source"})
				stack:take_item(1)
				return stack
			end
		})
end
