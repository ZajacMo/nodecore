-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_stone_bricks(name, desc, tile, alpha, bondalpha,
		madefrom, groups, bonded, mapcolor)
	groups = nodecore.underride(groups, {
			stone_bricks = 1,
			falling_node = 1
		})
	minetest.register_node(":" .. modname .. ":bricks_" .. name, {
			description = desc .. " Bricks",
			tiles = {tile .. "^(" .. modname .. "_bricks.png^[opacity:"
				.. alpha .. ")"},
			groups = groups,
			crush_damage = 2,
			sounds = nodecore.sounds("nc_terrain_stony"),
			mapcolor = mapcolor,
		})

	nodecore.register_craft({
			label = "chisel " .. name .. " bricks",
			discover = "chisel bricks",
			action = "pummel",
			toolgroups = {thumpy = 3},
			normal = {y = 1},
			indexkeys = {"group:chisel"},
			nodes = {
				{
					match = {
						lode_temper_cool = true,
						groups = {chisel = true}
					},
					dig = true
				},
				{
					y = -1,
					match = madefrom,
					replace = modname .. ":bricks_" .. name
				}
			}
		})

	bonded = nodecore.underride(bonded, groups)
	bonded.stone_bricks = 2
	bonded.falling_node = nil
	bonded.falling_mapgen_ignore = nil
	minetest.register_node(":" .. modname .. ":bricks_" .. name .. "_bonded", {
			description = "Bonded " .. desc .. " Bricks",
			tiles = {tile .. "^(" .. modname .. "_bricks.png^[opacity:"
				.. bondalpha .. ")"},
			groups = bonded,
			crush_damage = 2,
			sounds = nodecore.sounds("nc_terrain_stony"),
			mapcolor = mapcolor,
		})

	minetest.register_abm({
			label = "bond " .. name .. " bricks",
			nodenames = {modname .. ":bricks_" .. name},
			neighbors = {"group:concrete_wet"},
			neighbors_invert = true,
			interval = 1,
			chance = 2,
			action = function(pos)
				nodecore.set_loud(pos, {name = modname .. ":bricks_"
						.. name .. "_bonded"})
				nodecore.witness(pos, {
						"bond " .. name .. " bricks",
						"bond bricks"
					})
			end
		})
	nodecore.register_craft({
			label = "unbond " .. name .. " bricks",
			action = "pummel",
			toolgroups = {cracky = 4},
			indexkeys = {modname .. ":bricks_" .. name .. "_bonded"},
			nodes = {
				{
					match = modname .. ":bricks_" .. name .. "_bonded",
					replace = modname .. ":bricks_" .. name
				}
			}
		})
end

nodecore.register_stone_bricks("stone", "Stone",
	"nc_terrain_stone.png",
	240, 120,
	{groups = {smoothstone = true}},
	{stone = 1, rock = 1, cracky = 2},
	{cracky = 3, nc_door_scuff_opacity = 24},
	{r = 72, g = 72, b = 72}
)

minetest.register_alias(modname .. ":bricks", modname .. ":bricks_stone")
minetest.register_alias(modname .. ":bricks_bonded", modname .. ":bricks_stone_bonded")
