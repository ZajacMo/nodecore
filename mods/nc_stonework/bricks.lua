-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_stone_bricks(name, desc, tile, madefrom, groups, bonded)
	groups = nodecore.underride(groups, {
			falling_node = 1
		})
	minetest.register_node(":" .. modname .. ":bricks_" .. name, {
			description = desc .. " Bricks",
			tiles = {tile .. "^" .. modname .. "_bricks.png"},
			groups = groups,
			crush_damage = 2,
			sounds = nodecore.sounds("nc_terrain_stony")
		})

	nodecore.register_craft({
			label = "chisel " .. name .. " bricks",
			action = "pummel",
			toolgroups = {thumpy = 3},
			normal = {y = 1},
			indexkeys = {"group:chisel"},
			nodes = {
				{
					match = {
						metal_temper_cool = true,
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
	bonded.falling_node = nil
	minetest.register_node(":" .. modname .. ":bricks_" .. name .. "_bonded", {
			description = "Bonded " .. desc .. " Bricks",
			tiles = {tile .. "^(" .. modname .. "_bricks.png^[opacity:128)"},
			groups = bonded,
			crush_damage = 2,
			sounds = nodecore.sounds("nc_terrain_stony")
		})

	nodecore.register_limited_abm({
			label = "bond " .. name .. " bricks",
			nodenames = {modname .. ":bricks_" .. name},
			neighbors = {"group:concrete_wet"},
			interval = 1,
			chance = 2,
			action = function(pos)
				nodecore.set_loud(pos, {name = modname .. ":bricks_"
						.. name .. "_bonded"})
			end
		})
end

nodecore.register_stone_bricks("stone", "Stone",
	"nc_terrain_stone.png",
	{groups = {smoothstone = true}},
	{stone = 1, rock = 1, cracky = 2},
	{cracky = 3}
)

minetest.register_alias(modname .. ":bricks", modname .. ":bricks_stone")
minetest.register_alias(modname .. ":bricks_bonded", modname .. ":bricks_stone_bonded")
