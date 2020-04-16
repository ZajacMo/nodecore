-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local alldirs = nodecore.dirs()

local living = modname .. ":sponge_living"
local wet = modname .. ":sponge_wet"

local dryitems = {}
local drydrawtypes = {
	nodebox = true,
	signlike = true,
	mesh = true,
	allfaces_optional = true
}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_items) do
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
	if not node then return end
	if not dryitems[node.name] then return true end
	local def = minetest.registered_items[node.name]
	if def and def.groups.is_stack_only then
		local stack = nodecore.stack_get(pos)
		return minetest.get_item_group(stack:get_name(), "moist") > 0
	end
end

local function sealed_or_notdry(nodename, pos)
	if nodename == "nc_optics:shelf" then
		return (not pos) or notdry({x = pos.x, y = pos.y + 1, z = pos.z})
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

nodecore.register_limited_abm({
		label = "Sponge Growth",
		interval = 1,
		chance = 10,
		limited_max = 1000,
		nodenames = {living},
		action = function(pos, node)
			if not spongesurvive({pos = pos, node = node}) then
				nodecore.set_loud(pos, {name = wet})
				return nodecore.fallcheck(pos)
			end

			if math_random(1, 250) ~= 1 then return end

			local total = 0
			if nodecore.scan_flood(pos, 6,
				function(p, d)
					if d >= 6 then return true end
					if minetest.get_node(p).name ~= living then return false end
					total = total + 1
					if total >= 20 then return true end
				end
			) then return end

			pos = vector.add(pos, alldirs[math_random(1, #alldirs)])
			node = minetest.get_node_or_nil(pos)

			local def = node and minetest.registered_nodes[node.name]
			local grp = def and def.groups and def.groups.water
			if (not grp) or (grp < 1) then return end

			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			node = minetest.get_node(below)
			if (math_random() > 0.1) or (node.name ~= living) then
				def = minetest.registered_nodes[node.name]
				grp = def and def.groups and def.groups.sand
				if (not grp) or (grp < 1) then return end
			end
			nodecore.set_loud(pos, {name = living})
		end
	})

nodecore.register_aism({
		label = "Sponge Stack Survival",
		interval = 2,
		chance = 1,
		itemnames = {living},
		action = function(stack, data)
			if spongesurvive(data) then return end
			nodecore.sound_play("nc_terrain_swishy", {gain = 1, pos = data.pos})
			stack:set_name(wet)
			return stack
		end
	})
