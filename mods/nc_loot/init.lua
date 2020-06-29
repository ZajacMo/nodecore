-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()

local db = modstore:get_string("data")
db = db and db ~= "" and minetest.deserialize(db) or {}
local function savedb() return modstore:set_string("data", minetest.serialize(db)) end

local cid_cobble = minetest.get_content_id("nc_terrain:cobble")
local cid_air = minetest.get_content_id("air")

local function addloot(x, y, z, n)
	local pos = {x = x, y = y, z = z, n = n}
	local blockkey = minetest.pos_to_string({
			x = math_floor(x / 16),
			y = math_floor(y / 16),
			z = math_floor(z / 16)
		})
	local list = db[blockkey]
	if not list then
		list = {}
		db[blockkey] = list
	end
	list[#list + 1] = pos
end

nodecore.register_mapgen_shared({
		label = "dungeon loot",
		func = function(minp, maxp, area, data, _, _, _, rng)
			if minp.y > -64 then return end

			local ai = area.index
			local dirty

			for z = minp.z, maxp.z do
				for y = minp.y, maxp.y - 1 do
					local offs = ai(area, 0, y, z)
					for x = minp.x, maxp.x do
						local i = offs + x
						if data[i] == cid_cobble then
							local j = i + area.ystride
							if data[j] == cid_air
							and rng(1, 10) == 1 then
								addloot(x, y + 1, z,
									rng())
								dirty = true
							end
						end
					end
				end
			end

			if dirty then savedb() end
		end,
		priority = -100
	})

local function applyloot(pos)
	if minetest.get_node(pos).name ~= "air" then return end
	local set = {}
	for k in pairs(minetest.registered_nodes) do
		if k ~= "air" and k ~= "ignore" then
			set[#set + 1] = k
		end
	end
	local rng = nodecore.seeded_rng(pos.n)
	minetest.set_node(pos, {name = set[rng(1, #set)]})
end

minetest.register_globalstep(function()
		local dirty
		for blockkey, list in pairs(db) do
			local bpos = vector.multiply(minetest.string_to_pos(blockkey), 16)
			if minetest.get_node_or_nil(bpos) then
				for _, pos in pairs(list) do applyloot(pos) end
				db[blockkey] = nil
				dirty = true
			end
		end
		if dirty then savedb() end
	end)
