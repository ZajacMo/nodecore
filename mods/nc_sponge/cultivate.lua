-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, next, nodecore, pairs, table, vector
    = ipairs, math, minetest, next, nodecore, pairs, table, vector
local math_sqrt, table_shuffle
    = math.sqrt, table.shuffle
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local alldirs = nodecore.dirs()

local living = modname .. ":sponge_living"
local wet = modname .. ":sponge_wet"

local water = {}
local sand = {}

local dryitems = {}
local drydrawtypes = {
	nodebox = true,
	signlike = true,
	mesh = true,
	allfaces_optional = true
}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
			if v["type"] == "node" and v.groups.water then
				water[k] = true
			end
			if v["type"] == "node" and v.groups.sand then
				sand[k] = true
			end
			if v["type"] ~= "node" or (v.groups.damage_radiant or 0) > 0
			or v.liquidtype == "none" and not v.groups.moist
			and not v.groups.silica and (drydrawtypes[v.drawtype]
				or v.climbable or not v.walkable) then
				dryitems[k] = true
			end
		end
	end)

local function notdry(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return true end
	if not dryitems[node.name] then return true end
	local def = minetest.registered_items[node.name]
	if def and def.groups.is_stack_only then
		local stack = nodecore.stack_get(pos)
		return minetest.get_item_group(stack:get_name(), "moist") > 0
	end
end

local accessdirs = nodecore.dirs()
local function sealed_or_notdry(nodename, pos)
	local def = minetest.registered_nodes[nodename]

	if def and def.groups and def.groups.storebox_sealed_always
	and def.groups.storebox_sealed_always > 0 then return true end

	if def and def.groups and def.groups.storebox_sealed
	and def.groups.storebox_sealed > 0 then
		if not pos then return true end
		for i = 1, #accessdirs do
			local pt = {
				type = "node",
				above = vector.add(accessdirs[i], pos),
				under = pos
			}
			if (not def.storebox_access) or def.storebox_access(pt, pos,
				{name = nodename, param = 0, param2 = 0}) then
				if not notdry(pt.above) then return end
			end
		end
		return true
	end

	if not pos then return end
	for _, d in pairs(alldirs) do
		if not notdry(vector.add(pos, d)) then return end
	end

	return true
end

local function spongesurvive(data)
	if data.toteslot then
		return sealed_or_notdry(data.toteslot.n.name)
	elseif data.node then
		return sealed_or_notdry(data.node.name, data.pos)
	elseif data.inv then
		return notdry(data.pos)
	end
end
nodecore.spongesurvive = spongesurvive

nodecore.register_dnt({
		name = modname .. ":spongedie",
		nodenames = {living},
		time = 2,
		action = function(pos, node)
			if not spongesurvive({pos = pos, node = node}) then
				nodecore.set_loud(pos, {name = wet})
				return nodecore.fallcheck(pos)
			end
		end
	})
minetest.register_abm({
		label = "sponge death",
		interval = 2,
		chance = 5,
		nodenames = {living},
		arealoaded = 1,
		action = function(pos, node)
			if not spongesurvive({pos = pos, node = node}) then
				nodecore.dnt_set(pos, modname .. ":spongedie")
			end
		end
	})

nodecore.register_aism({
		label = "sponge stack death",
		interval = 2,
		chance = 1,
		arealoaded = 1,
		itemnames = {living},
		action = function(stack, data)
			if spongesurvive(data) then return end
			nodecore.sound_play("nc_terrain_swishy", {gain = 1, pos = data.pos})
			stack:set_name(wet)
			return stack
		end
	})

local growdirs = {}
for _, p in pairs(nodecore.dirs()) do
	if p.y >= 0 then growdirs[#growdirs + 1] = p end
end

local hashpos = minetest.hash_node_position

-- Sponge colonies may only grow one node per pass; keep track of positions
-- of sponges that were already checked to avoid doing the floodfill check
-- for each one, which would lead to O(n^2) complexity.
local spongeskip = {}
minetest.register_globalstep(function() if next(spongeskip) then spongeskip = {} end end)

local maxdist = 6
local basecost = 2000
nodecore.register_soaking_abm({
		label = "sponge grow",
		fieldname = "spongegrow",
		nodenames = {living},
		interval = 5,
		chance = 2,
		arealoaded = 6,
		soakrate = function() return 2 end,
		soakcheck = function(data, pos)
			if data.total < basecost then return end

			if spongeskip[hashpos(pos)] then return end

			local waternear = {}

			local minx = pos.x
			local maxx = pos.x
			local miny = pos.y
			local maxy = pos.y
			local minz = pos.z
			local maxz = pos.z
			local count = 0
			if nodecore.scan_flood(pos, maxdist,
				function(p, d)
					if d >= maxdist then return true end
					if p.x < minx then
						minx = p.x
						if maxx - minx > maxdist then return true end
					elseif p.x > maxx then
						maxx = p.x
						if maxx - minx > maxdist then return true end
					end
					if p.y < miny then
						miny = p.y
						if maxy - miny > maxdist then return true end
					elseif p.y > maxy then
						maxy = p.y
						if maxy - miny > maxdist then return true end
					end
					if p.z < minz then
						minz = p.z
						if maxz - minz > maxdist then return true end
					elseif p.z > maxz then
						maxz = p.z
						if maxz - minz > maxdist then return true end
					end
					local nn = minetest.get_node(p).name
					if water[nn] then waternear[#waternear + 1] = p end
					if nn ~= living then return false end
					spongeskip[hashpos(p)] = true
					count = count + 1
					if count >= 20 then return true end
				end
			) then return false end
			local realcost = basecost * math_sqrt(count)
			if data.total < realcost then return end

			table_shuffle(waternear)
			for _, dest in ipairs(waternear) do
				local below = {x = dest.x, y = dest.y - 1, z = dest.z}
				local node = minetest.get_node(below)
				if node.name == living or sand[node.name] then
					nodecore.set_loud(dest, {name = living})
					return data.total - realcost
				end
			end
			return false
		end
	})
