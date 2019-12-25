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
local spongewet = modname .. ":sponge_wet"

local function mkwater(pos, srcpos, new)
	if new then
		minetest.set_node(pos, {name = watersrc})
		nodecore.node_sound(pos, "place")
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("spongepos", minetest.pos_to_string(srcpos))
	meta:set_float("expire", nodecore.gametime + 10)
end

nodecore.register_craft({
		label = "squeeze sponge",
		action = "pummel",
		toolgroups = {thumpy = 1},
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
				if nn == "air" or nn == watersrc then
					mkwater(p, pos, nn ~= watersrc)
					found = true
				end
			end
			if found then nodecore.node_sound(pos, "dig") end
		end
	})

local function rmwater(pos)
	return minetest.set_node(pos, {name = "nc_terrain:water_gray_flowing", param2 = 7})
end

nodecore.register_limited_abm({
		interval = 1,
		chance = 1,
		nodenames = {watersrc},
		action = function(pos)
			local meta = minetest.get_meta(pos)
			local srcpos = meta:get_string("spongepos") or ""
			if srcpos == "" then return end
			srcpos = minetest.string_to_pos(srcpos)
			local snode = minetest.get_node(srcpos)
			if snode.name == "ignore" then return end
			if snode.name ~= spongewet then return rmwater(pos) end
			local expire = meta:get_float("expire") or 0
			if nodecore.gametime > expire then return rmwater(pos) end
		end
	})
