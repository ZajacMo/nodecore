-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor, math_pow, math_random
    = math.floor, math.pow, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

------------------------------------------------------------------------
-- Hard Stone Strata

nodecore.hard_stone_strata = 7

function nodecore.hard_stone_tile(n)
	local o = math_floor(math_pow(n, 0.75) * 59)
	if o <= 0 then
		return modname .. "_stone.png"
	end
	if o >= 255 then
		return modname .. "_stone.png^"
		.. modname .. "_stone_hard.png"
	end
	return modname .. "_stone.png^("
	.. modname .. "_stone_hard.png^[opacity:"
	.. o .. ")"
end

------------------------------------------------------------------------
-- Dirt Leaching

function nodecore.register_dirt_leaching(fromnode, tonode, rate)
	local function waterat(pos, dx, dy, dz)
		pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
		local node = minetest.get_node(pos)
		return minetest.get_item_group(node.name, "water") ~= 0
	end
	nodecore.register_soaking_abm({
			label = fromnode .. " leaching to " .. tonode,
			fieldname = "leach",
			nodenames = {fromnode},
			neighbors = {"group:water"},
			interval = 5,
			chance = 1,
			soakrate = function(pos)
				if not waterat(pos, 0, 1, 0) then return false end
				local qty = 1
				if waterat(pos, 1, 0, 0) then qty = qty * 1.5 end
				if waterat(pos, -1, 0, 0) then qty = qty * 1.5 end
				if waterat(pos, 0, 0, 1) then qty = qty * 1.5 end
				if waterat(pos, 0, 0, -1) then qty = qty * 1.5 end
				if waterat(pos, 0, -1, 0) then qty = qty * 1.5 end
				return qty * (rate or 1)
			end,
			soakcheck = function(data, pos)
				if data.total < 5000 then return end
				nodecore.witness(pos, "leach " .. fromnode)
				nodecore.set_loud(pos, {name = tonode})
				return nodecore.fallcheck(pos)
			end
		})
end

------------------------------------------------------------------------
-- Artificial Water

local graywatersrc = "nc_terrain:water_gray_source"
local graywaterflow = "nc_terrain:water_gray_flowing"
local graywatercache = {}

local function rmwater(pos)
	nodecore.node_sound(pos, "dig")
	return minetest.set_node(pos, {name = graywaterflow, param2 = 7})
end
function nodecore.artificial_water_check(pos)
	local data = graywatercache[minetest.hash_node_position(pos)]
	if not data then
		data = minetest.get_meta(pos):get_string(modname)
		data = data and data ~= "" and minetest.deserialize(data)
	end
	if not data then return rmwater(pos) end

	if data.recheck and nodecore.gametime < data.recheck then
		return nodecore.dnt_set(pos, graywatersrc, data.recheck - nodecore.gametime)
	end
	if data.expire and nodecore.gametime >= data.expire then
		return rmwater(pos)
	end

	if data.matchpos and data.match then
		local mnode = minetest.get_node(data.matchpos)
		if mnode.name ~= "ignore" and not nodecore.match(mnode, data.match) then
			return rmwater(pos)
		end
	end

	return nodecore.dnt_set(pos, graywatersrc, 1 + math_random())
end

nodecore.register_dnt({
		name = graywatersrc,
		nodenames = {graywatersrc},
		action = function(pos) return nodecore.artificial_water_check(pos) end
	})

nodecore.register_limited_abm({
		label = "artificial water check",
		interval = 1,
		chance = 1,
		nodenames = {graywatersrc},
		action = function(pos) return nodecore.artificial_water_check(pos) end
	})

--[[
artificial water def:
- matchpos = position of node that's producing the water
- match = match criteria to check that water-producing node is still present
- minttl = minimum amount of time water must be there before rechecking for valid source
- maxttl = maximum amount of time water will remain without being updated
--]]
function nodecore.artificial_water(pos, def)
	local nn = minetest.get_node(pos).name
	if nn ~= graywatersrc and nn ~= graywaterflow then
		nodecore.set_loud(pos, {name = graywatersrc})
	end
	local meta = minetest.get_meta(pos)
	local data = {
		match = def.match,
		matchpos = def.matchpos,
		recheck = def.minttl and nodecore.gametime + def.minttl,
		expire = def.maxttl and nodecore.gametime + def.maxttl
	}
	meta:set_string(modname, minetest.serialize(data))
	graywatercache[minetest.hash_node_position(pos)] = data
	return nodecore.dnt_set(pos, graywatersrc, def.minttl or 1)
end
