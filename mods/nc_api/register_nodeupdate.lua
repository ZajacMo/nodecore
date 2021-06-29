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

if minetest.register_on_fluid_transformed then
	local fluids = 0
	local time = 0
	local function fluidrpt()
		nodecore.log("warning", "handled fluid transform for "
			.. fluids .. " nodes over " .. (time / 1000000)
			.. " seconds")
		fluids = 0
		time = 0
		minetest.after(10, fluidrpt)
	end
	minetest.after(10, fluidrpt)
	minetest.register_on_fluid_transformed(function(list)
			local started = minetest.get_us_time()
			for i = 1, #list do
				local pos = list[i].pos
				local phash = hash(pos)
				if not mask[phash] then
					mask[phash] = true
					fluids = fluids + 1
					local node = minetest.get_node(pos)
					for j = 1, #nodecore.registered_on_nodeupdates do
						(nodecore.registered_on_nodeupdates[j])(pos, node)
					end
					mask[phash] = nil
				end
			end
			time = time + minetest.get_us_time() - started
		end)
end
