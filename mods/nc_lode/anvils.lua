-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, type
    = ipairs, math, minetest, nodecore, type
local math_random
    = math.random
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
		arealoaded = 1,
		action = function(pos)
			if nodecore.quenched(pos) or #nodecore.find_nodes_around(
				pos, "group:flame", 1) < 1 then
				return nodecore.set_loud(pos, {name = "nc_terrain:cobble"})
			end
		end
	})

local anvillogic = {
	-- Tempered anvils can work hot or cold
	["annealed/" .. modname .. ":block_tempered"] = true,
	["hot/" .. modname .. ":block_tempered"] = true,

	-- Annealed anvils only work hot
	["hot/" .. modname .. ":block_annealed"] = true,

	-- Smooth stone turns into cracked stone and only works
	-- as long as it remains cracked stone.
	["hot/nc_terrain:stone"] = function(pos)
		return function()
			nodecore.set_loud(pos, {name = cracked})
		end
	end,
	["hot/" .. cracked] = true,
}
-- Hard stone is weakened probabilistically, but at half
-- the rate for each layer of hardness.
for i = 1, nodecore.hard_stone_strata do
	anvillogic["hot/nc_terrain:hard_stone_" .. i] = function(pos)
		return function()
			if math_random(1, 2 ^ i) ~= 1 then return end
			nodecore.set_loud(pos, {name = (i == 1)
					and "nc_terrain:stone"
					or ("nc_terrain:hard_stone_" .. (i - 1))
				})
		end
	end
end

local function chain(func, oldfunc)
	if not oldfunc then return func end
	return function(...)
		local r = func(...)
		if not r then return r end
		return oldfunc(...)
	end
end

-- nodecore.register_lode_anvil_recipe(anvilpos, function(temper) end)
-- - anvilpos can be a table or a number (bare relative y value)
-- - temper is a string to be inserted into recipe item/node names
-- the anvil node is added to the recipe automatically at anvilpos
function nodecore.register_lode_anvil_recipe(anvilpos, func)
	local anvilx = 0
	local anvily
	local anvilz = 0
	if type(anvilpos) == "number" then
		anvily = anvilpos
	else
		anvilx = anvilpos.x or 0
		anvily = anvilpos.y or 0
		anvilz = anvilpos.z or 0
	end
	for _, temper in ipairs({"hot", "annealed"}) do
		local recipe = func(temper)
		recipe.check = chain(function(_, data)
				local pos = data.rel(anvilx, anvily, anvilz)
				local node = minetest.get_node(pos)
				local logic = anvillogic[temper .. "/" .. node.name]
				if not logic then return end
				if logic == true then return true end
				data.anvilcommit = logic(pos)
				return true
			end,
			recipe.check)
		recipe.after = chain(function(_, data)
				if data.anvilcommit then data.anvilcommit() end
			end,
			recipe.after)
		nodecore.register_craft(recipe)
	end
end
