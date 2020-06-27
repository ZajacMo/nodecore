-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local spongedirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1}
}

local watersrc = "nc_terrain:water_gray_source"
local waterflow = "nc_terrain:water_gray_flowing"
local spongewet = modname .. ":sponge_wet"

local spongecache = {}

local function mkwater(pos, srcpos, new)
	if new then nodecore.set_loud(pos, {name = watersrc}) end
	local meta = minetest.get_meta(pos)
	local data = {
		srcpos = srcpos,
		expire = nodecore.gametime + 10
	}
	meta:set_string(modname, minetest.serialize(data))
	spongecache[minetest.hash_node_position(pos)] = data
end

nodecore.register_craft({
		label = "squeeze sponge",
		action = "pummel",
		toolgroups = {thumpy = 1},
		indexkeys = {spongewet},
		nodes = {
			{
				match = spongewet
			}
		},
		after = function(pos)
			local found
			for _, d in pairs(spongedirs) do
				local p = vector.add(pos, d)
				local nn = minetest.get_node(p).name
				if nn == "air" or nn == watersrc
				or nn == waterflow then
					mkwater(p, pos, nn ~= watersrc)
					found = true
				end
			end
			if found then nodecore.node_sound(pos, "dig") end
		end
	})

local function rmwater(pos)
	nodecore.node_sound(pos, "dig")
	return minetest.set_node(pos, {name = waterflow, param2 = 7})
end

nodecore.register_limited_abm({
		label = "sponge water check",
		interval = 1,
		chance = 1,
		nodenames = {watersrc},
		action = function(pos)
			local data = spongecache[minetest.hash_node_position(pos)]
			if not data then
				data = minetest.get_meta(pos):get_string(modname)
				data = data and data ~= "" and minetest.deserialize(data)
			end
			if not data then return rmwater(pos) end
			local snode = minetest.get_node(data.srcpos)
			if snode.name == "ignore" then return end
			if snode.name ~= spongewet then return rmwater(pos) end
			if nodecore.gametime > data.expire then return rmwater(pos) end
		end
	})
