-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_nodeupdate,
nodecore.registered_on_nodeupdates
= nodecore.mkreg()

local hash = minetest.hash_node_position

local mask = {}

for fn, param in pairs({
		set_node = true,
		add_node = true,
		remove_node = false,
		swap_node = true,
		dig_node = false,
		place_node = true,
		add_node_level = false
	}) do
	local func = minetest[fn]
	minetest[fn] = function(pos, pn, ...)
		local phash = hash(pos)
		if mask[phash] then return func(pos, pn, ...) end
		mask[phash] = true
		local function helper(...)
			local node = param and pn or minetest.get_node(pos)
			for i = 1, #nodecore.registered_on_nodeupdates do
				(nodecore.registered_on_nodeupdates[i])(pos, node)
			end
			mask[phash] = nil
			return ...
		end
		return helper(func(pos, pn, ...))
	end
end

if minetest.register_on_liquid_transformed then
	minetest.register_on_liquid_transformed(function(list)
			for i = 1, #list do
				local pos = list[i]
				local phash = hash(pos)
				if not mask[phash] then
					mask[phash] = true
					local node = minetest.get_node(pos)
					for j = 1, #nodecore.registered_on_nodeupdates do
						(nodecore.registered_on_nodeupdates[j])(pos, node)
					end
					mask[phash] = nil
				end
			end
		end)
end
