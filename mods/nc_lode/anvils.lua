-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local cracked = modname .. ":stone_cracked"

minetest.register_node(cracked, {
		description = "Cracked Stone",
		is_ground_content = true,
		tiles = {"nc_terrain_stone.png^" .. modname .. "_stone_cracked.png"},
		drop_in_place = "nc_terrain:cobble",
		silktouch_as = "nc_terrain:cobble",
		groups = {
			cracky = 1,
			stone = 1,
			rock = 1,
		},
		sounds = nodecore.sounds("nc_terrain_stony"),
	})

-- Cracked stone remains only as long as hot, converts down to cobble.
minetest.register_abm({
		label = "cracked stone cooldown",
		nodenames = {cracked},
		interval = 1,
		chance = 1,
		action = function(pos)
			if nodecore.quenched(pos) or #nodecore.find_nodes_around(
				pos, "group:flame", 1) < 1 then
				return nodecore.set_loud(pos, {name = "nc_terrain:cobble"})
			end
		end
	})

-- nodecore.register_lode_anvil_recipe(anvilpos, function(temper) end)
-- - anvilpos can be a table or a number (bare relative y value)
-- - temper is a string to be inserted into recipe item/node names
-- the anvil node is added to the recipe automatically at anvilpos
function nodecore.register_lode_anvil_recipe(anvilpos, func)
	if type(anvilpos) == "number" then anvilpos = {y = anvilpos} end

	local function register(anvil, temper, label)
		for k, v in pairs(anvilpos) do anvil[k] = v end
		local recipe = func(temper)
		recipe.discover = {recipe.label, "anvil:" .. label}
		recipe.label = recipe.label .. " (" .. label .. ")"
		recipe.nodes = recipe.nodes or {}
		recipe.nodes[#recipe.nodes + 1] = anvil
		return nodecore.register_craft(recipe)
	end

	-- Tempered anvils can work hot or cold
	register({match = modname .. ":block_tempered"}, "annealed", "cold/tempered")
	register({match = modname .. ":block_tempered"}, "hot", "hot/tempered")

	-- Annealed anvils only work hot
	register({match = modname .. ":block_annealed"}, "hot", "hot/annealed")

	-- Smooth stone turns into cracked stone and only works
	-- as long as it remains cracked stone.
	register({match = "nc_terrain:stone", replace = cracked}, "hot", "hot/stone")
	register({match = cracked}, "hot", "hot/stone")

	-- Hard stone is weakened probabilistically, but at half
	-- the rate for each layer of hardness.
	for i = 1, nodecore.hard_stone_strata do
		register({
				match = "nc_terrain:hard_stone_" .. i,
				replace = (i == 1) and "nc_terrain:stone"
				or ("nc_terrain:hard_stone_" .. (i - 1)),
				chance = 2 ^ i
			}, "hot", "hot/stone")
	end
end
