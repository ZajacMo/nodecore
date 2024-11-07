-- LUALOCALS < ---------------------------------------------------------
local core, math, nc
    = core, math, nc
local math_floor, math_pow, math_random
    = math.floor, math.pow, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

------------------------------------------------------------------------
-- Hard Stone Strata

nc.hard_stone_strata = 7

function nc.hard_stone_tile(n)
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
-- Artificial Water

local graywatersrc = "nc_terrain:water_gray_source"
local graywaterflow = "nc_terrain:water_gray_flowing"
local graywatercache = {}

local function rmwater(pos)
	nc.node_sound(pos, "dig")
	return core.set_node(pos, {name = graywaterflow, param2 = 7})
end
function nc.artificial_water_check(pos)
	local cachekey = core.hash_node_position(pos)
	local data = graywatercache[cachekey]
	if not data then
		data = core.get_meta(pos):get_string(modname)
		data = data and data ~= "" and core.deserialize(data)
		graywatercache[cachekey] = data
	end
	if not data then return rmwater(pos) end

	if data.recheck and nc.gametime < data.recheck then
		return nc.dnt_set(pos, graywatersrc, data.recheck - nc.gametime)
	end

	if nc.near_inactive(pos, nil, 3) then
		return nc.dnt_set(pos, graywatersrc, 1 + math_random())
	end

	if data.expire and nc.gametime >= data.expire then
		return rmwater(pos)
	end

	if data.matchpos and data.match then
		local mnode = core.get_node(data.matchpos)
		if mnode.name ~= "ignore" and not nc.match(mnode, data.match) then
			return rmwater(pos)
		end
	end

	return nc.dnt_set(pos, graywatersrc, 1 + math_random())
end

nc.register_dnt({
		name = graywatersrc,
		nodenames = {graywatersrc},
		arealoaded = 1,
		autostart = true,
		autostart_time = 0,
		action = function(pos) return nc.artificial_water_check(pos) end
	})

--[[
artificial water def:
- matchpos = position of node that's producing the water
- match = match criteria to check that water-producing node is still present
- minttl = minimum amount of time water must be there before rechecking for valid source
- maxttl = maximum amount of time water will remain without being updated
--]]
function nc.artificial_water(pos, def, node)
	node = node or core.get_node(pos)
	local nn = node.name
	if nn ~= graywatersrc then
		if nn ~= graywaterflow then
			local nd = core.registered_nodes[nn]
			if not (nd and nd.floodable) then return end
			if nd.on_flood and not nd.on_flood(
				pos, node, {name = graywatersrc}) then return end
		end
		nc.set_loud(pos, {name = graywatersrc})
	end
	local meta = core.get_meta(pos)
	local data = {
		match = def.match,
		matchpos = def.matchpos,
		recheck = def.minttl and nc.gametime + def.minttl,
		expire = def.maxttl and nc.gametime + def.maxttl
	}
	meta:set_string(modname, core.serialize(data))
	graywatercache[core.hash_node_position(pos)] = data
	nc.dnt_set(pos, graywatersrc, def.minttl or 1)
	return true
end
