-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, math, nc, type
    = core, ipairs, math, nc, type
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local cracked = modname .. ":stone_cracked"

core.register_node(cracked, {
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
		sounds = nc.sounds("nc_terrain_stony"),
		mapcolor = {r = 72, g = 72, b = 72},
	})

-- Cracked stone remains only as long as hot, converts down to cobble.
core.register_abm({
		label = "cracked stone cooldown",
		nodenames = {cracked},
		interval = 1,
		chance = 1,
		arealoaded = 1,
		action = function(pos)
			if nc.quenched(pos) or #nc.find_nodes_around(
				pos, "group:flame", 1) < 1 then
				return nc.set_loud(pos, {name = "nc_terrain:cobble"})
			end
		end
	})

local function discoveranvil(data, tag)
	if not (data and data.crafter) then return end
	return nc.player_discover(data.crafter, tag)
end

local anvillogic = {
	-- Tempered anvils can work hot or cold
	["annealed/" .. modname .. ":block_tempered"] = "anvil:cold/tempered",
	["hot/" .. modname .. ":block_tempered"] = "anvil:hot/tempered",

	-- Annealed anvils only work hot
	["hot/" .. modname .. ":block_annealed"] = "anvil:hot/annealed",

	-- Smooth stone turns into cracked stone and only works
	-- as long as it remains cracked stone.
	["hot/nc_terrain:stone"] = function(pos)
		return function(data)
			discoveranvil(data, "anvil:hot/stone")
			nc.set_loud(pos, {name = cracked})
		end
	end,
	["hot/" .. cracked] = "anvil:hot/stone",
}
-- Hard stone is weakened probabilistically, but at half
-- the rate for each layer of hardness.
for i = 1, nc.hard_stone_strata do
	anvillogic["hot/nc_terrain:hard_stone_" .. i] = function(pos)
		return function(data)
			discoveranvil(data, "anvil:hot/stone")
			if math_random(1, 2 ^ i) ~= 1 then return end
			nc.set_loud(pos, {name = (i == 1)
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

-- nc.register_lode_anvil_recipe(anvilpos, function(temper) end)
-- - anvilpos can be a table or a number (bare relative y value)
-- - temper is a string to be inserted into recipe item/node names
-- the anvil node is added to the recipe automatically at anvilpos
function nc.register_lode_anvil_recipe(anvilpos, func)
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
		if recipe then
			recipe.check = chain(function(_, data)
					local pos = data.rel(anvilx, anvily, anvilz)
					local node = core.get_node(pos)
					local logic = anvillogic[temper .. "/" .. node.name]
					if not logic then return end
					data.anvilcommit = type(logic) == "function"
					and logic(pos)
					or function(d) return discoveranvil(d, logic) end
					return true
				end,
				recipe.check)
			recipe.after = chain(function(_, data)
					if data.anvilcommit then data.anvilcommit(data) end
					return nc.player_discover(data.crafter, "lode anvil")
				end,
				recipe.after)
			nc.register_craft(recipe)
		end
	end
end
