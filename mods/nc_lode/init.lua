-- LUALOCALS < ---------------------------------------------------------
local VoxelArea, minetest, nodecore
    = VoxelArea, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function reg(suff, def)
	def = nodecore.underride(def, {
			description = "Lode " .. suff,
			name = suff:lower(),
			is_ground_content = true,
			groups = { cracky = 2 }
		})
	def.fullname = modname .. ":" .. def.name
	def.oldnames = {"nc_iron:" .. def.name}

	minetest.register_node(def.fullname, def)

	return def.fullname
end

local stone = reg("Stone", {
		tiles = { "nc_terrain_stone.png^(" .. modname .. "_raw.png^[opacity:48)" },
		drop_in_place = "nc_terrain:cobble"
		})
local ore = reg("Ore", {
		tiles = { "nc_terrain_stone.png^" .. modname .. "_raw.png^[opacity:128" },
		drop_in_place = modname .. ":cobble"
		})
reg("Cobble", {
		tiles = { modname .. "_raw.png^[noalpha^nc_terrain_cobble.png" },
		alternate_loose = {
			repack_level = 2,
			groups = {
				cracky = 0,
				crumbly = 1,
				falling_repose = 3
			}
		}
	})

local function regore(name, def)
	return minetest.register_ore(nodecore.underride(def, {
				name = name,
				ore_type = "scatter",
				ore = name,
				wherein = "nc_terrain:stone",
				random_factor = 0,
				noise_params = {
					offset  = 0,
					scale   = 4,
					spread  = {x=40, y=5, z=40},
					seed    = 12497,
					octaves = 3,
					persist = 0.5,
					flags = "eased",
				},
				noise_threshold = 1.3		
				}, def))
end
regore(ore, {
		clust_num_ores = 16,
		clust_size = 3,
		clust_scarcity = 8 * 8 * 8,
	})
regore(stone, {
		clust_num_ores = 4,
		clust_size = 3,
		clust_scarcity = 2 * 2 * 2,
	})

local c_ore = minetest.get_content_id(ore)
local c_istone = minetest.get_content_id(stone)
local c_stone = minetest.get_content_id("nc_terrain:stone")

minetest.register_on_generated(function(minp, maxp)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

		local function bad(x, y, z)
			local c = data[area:index(x, y, z)]
			return c ~= c_stone and c ~= c_istone
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
						then data[i] = c_istone
						end
					end
				end
			end
		end

		vm:set_data(data)
		vm:set_lighting{day = 0, night = 0}
		vm:calc_lighting()
		vm:write_to_map()
	end)
