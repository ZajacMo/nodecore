-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_pow
    = math.pow
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function reg(suff, def)
	def = nodecore.underride(def, {
			description = "Lode " .. suff,
			name = suff:lower(),
			is_ground_content = true,
			groups = { cracky = 2 },
			sounds = nodecore.sounds("nc_terrain_stony")
		})
	def.fullname = modname .. ":" .. def.name
	def.oldnames = {"nc_iron:" .. def.name}

	minetest.register_node(def.fullname, def)

	return def.fullname
end

local stratstone = {}
local stratore = {}
local stone = reg("Stone", {
		description = "Stone",
		tiles = { "nc_terrain_stone.png^(" .. modname .. "_ore.png^[mask:"
			.. modname .. "_mask_ore.png^[opacity:48)" },
		drop_in_place = "nc_terrain:cobble",
		strata = stratstone
	})
stratstone[1] = stone
local ore = reg("Ore", {
		tiles = { "nc_terrain_stone.png^(" .. modname .. "_ore.png^[mask:"
			.. modname .. "_mask_ore.png)" },
		drop_in_place = modname .. ":cobble",
		strata = stratore
	})
stratore[1] = ore
for i = 1, nodecore.hard_stone_strata do
	local hst = nodecore.hard_stone_tile(i)
	stratstone[i + 1] = reg("Stone_" .. i, {
			description = "Stone",
			tiles = { hst .. "^(" .. modname .. "_ore.png^[mask:"
				.. modname .. "_mask_ore.png^[opacity:48)" },
			drop_in_place = modname .. ((i > 1)
				and (":stone_" .. (i - 1)) or ":stone"),
			strata = stratstone,
			groups = {cracky = i + 2}
		})

	stratore[i + 1] = reg("Ore_" .. i, {
			description = "Lode Ore",
			tiles = { hst .. "^(" .. modname .. "_ore.png^[mask:"
				.. modname .. "_mask_ore.png)" },
			drop_in_place = modname .. ":cobble",
			strata = stratore,
			groups = {cracky = i + 2}
		})
end

reg("Cobble", {
		tiles = { modname .. "_ore.png^nc_terrain_cobble.png" },
		alternate_loose = {
			repack_level = 2,
			groups = {
				cracky = 0,
				crumbly = 2,
				falling_repose = 3
			},
			sounds = nodecore.sounds("nc_terrain_chompy")
		}
	})

local function regore(name, def, num)
	return minetest.register_ore(nodecore.underride(def, {
				name = name .. (num and "_" .. num or ""),
				ore_type = "scatter",
				ore = name,
				wherein = "nc_terrain:stone",
				random_factor = 0,
				noise_params = {
					offset  = 0,
					scale   = 4,
					spread  = {x = 40, y = 5, z = 40},
					seed    = 12497,
					octaves = 3,
					persist = 0.5,
					flags = "eased",
				},
				noise_threshold = 1.3		
				}, def))
end
for y = 0, 7 do
	local def = {
		y_max = 64 - 32 * math_pow(2, y),
		y_min = 64 - 32 * math_pow(2, y + 1),
		clust_num_ores = 16,
		clust_size = 3,
		clust_scarcity = 8 * 8 * 8 / math_pow(1.5, y),
	}
	if y == 7 then def.y_min = nil end
	regore(ore, def, y)
end
regore(stone, {
		y_max = 32,
		clust_num_ores = 4,
		clust_size = 3,
		clust_scarcity = 2 * 2 * 2,
	})

local c_ore = minetest.get_content_id(ore)
local stoneids = {}
local stratadata = nodecore.stratadata()
local c_lodestone = minetest.get_content_id(stone)
for _, id in pairs({
		c_lodestone,
		minetest.get_content_id(ore),
		minetest.get_content_id("nc_terrain:stone")
		}) do
	stoneids[id] = true
	for _, v in pairs(stratadata.altsbyid[id] or {}) do
		stoneids[v] = true
	end
end

nodecore.register_mapgen_shared(function(minp, maxp, area, data, vm, emin, emax)
		local function bad(x, y, z)
			local c = data[area:index(x, y, z)]
			return not stoneids[c]
		end

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
					local i = area:index(x, y, z)
					if data[i] == c_ore then
						if x == minp.x
						or x == maxp.x
						or y == minp.y
						or y == maxp.y
						or z == minp.z
						or z == maxp.z
						or bad(x + 1, y, z)
						or bad(x - 1, y, z)
						or bad(x, y + 1, z)
						or bad(x, y - 1, z)
						or bad(x, y, z + 1)
						or bad(x, y, z - 1)
						then data[i] = c_lodestone
						end
					end
				end
			end
		end
	end)
