-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local pumname = modname .. ":pumice"

local pumdef
pumdef = {
	description = "Pumice",
	tiles = {"nc_igneous_pumice.png"},
	groups = {
		snappy = 2,
		cracky = 2,
		stack_as_node = 1,
		cheat = 1,
		pumice = 1,
	},
	drop = "",
	destroy_on_dig = true,
	silktouch = false,
	sounds = nodecore.sounds("nc_optics_glassy", nil, 0.8),
	mapcolor = {r = 79, g = 79, b = 79},
}
minetest.register_node(pumname, pumdef)

do
	local dirs = nodecore.dirs()
	minetest.register_abm({
			label = "lava pumice",
			interval = 1,
			chance = 2,
			nodenames = {"nc_terrain:lava_flowing"},
			neighbors = {"group:coolant"},
			action = function(pos)
				if math_random() < 0.5 then
					local p = vector.add(pos, dirs[math_random(1, #dirs)])
					local n = minetest.get_node(p)
					if minetest.get_item_group(n.name, "water") > 0 then
						return nodecore.set_loud(p, {name = pumname})
					end
				end
				return nodecore.set_loud(pos, {name = pumname})
			end
		})
end

minetest.register_abm({
		label = "pumice melt",
		interval = 1,
		chance = 2,
		nodenames = {pumname},
		neighbors = {"group:lava"},
		arealoaded = 1,
		action = function(pos)
			if math_random() < 0.95 and nodecore.quenched(pos) then return end
			nodecore.set_loud(pos, {name = "nc_terrain:lava_flowing", param2 = 7})
			pos.y = pos.y + 1
			return nodecore.fallcheck(pos)
		end
	})

-- Pumice structues slowly collapse unless any of the following:
-- - supported directly below or directly on a side
-- - pumice immediately to the side that's supported below
-- - a supported "bridge" with gap not more than 3

local pumices = {ignore = true}
local supports = {ignore = true}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			local grp = v.groups or {}
			if (grp.pumice or 0) > 0 then
				pumices[k] = true
			elseif (grp.pumice_no_support or 0) <= 0 then
				if (grp.pumice_support or 0) > 0
				or (grp.falling_node or 0) <= 0
				and v.drawtype == "normal" then
					supports[k] = true
				end
			end
		end
	end)

-- true = supported, nil = bridge, false = open
local function checksupport(pos)
	local nn = minetest.get_node(pos).name
	if supports[nn] then return true end
	if not pumices[nn] then return false end
	local bpos = {x = pos.x, y = pos.y - 1, z = pos.z}
	local bn = minetest.get_node(bpos).name
	return supports[bn]
end
local function checkbridge(pos, dx, dy, dz)
	return checksupport(vector.offset(pos, dx, dy, dz))
	and checksupport(vector.offset(pos, -dx, -dy, -dz))
end

local max_entities = 50
local estimated_falling_ents = 0
minetest.register_globalstep(function()
		estimated_falling_ents = 0
		for _, ent in pairs(minetest.luaentities) do
			if ent.name == "__builtin:falling_node" then
				estimated_falling_ents = estimated_falling_ents + 1
				if estimated_falling_ents >= max_entities then return end
			end
		end
	end)

minetest.register_abm({
		label = "pumice collapse",
		interval = 1,
		chance = 100,
		nodenames = {pumname},
		arealoaded = 1,
		action = function(pos, node)
			if estimated_falling_ents >= max_entities then return end

			local bpos = {x = pos.x, y = pos.y - 1, z = pos.z}
			if not nodecore.buildable_to(bpos) then return end

			local e = checksupport({x = pos.x + 1, y = pos.y, z = pos.z})
			if e then return end
			local w = checksupport({x = pos.x - 1, y = pos.y, z = pos.z})
			if w then return end
			local n = checksupport({x = pos.x, y = pos.y, z = pos.z + 1})
			if n then return end
			local s = checksupport({x = pos.x, y = pos.y, z = pos.z - 1})
			if s then return end

			if e ~= false and w ~= false and checkbridge(pos, 2, 0, 0)
			or n ~= false and s ~= false and checkbridge(pos, 0, 0, 2)
			then return end

			estimated_falling_ents = estimated_falling_ents + 1

			nodecore.node_sound(pos, "fall")
			minetest.spawn_falling_node(pos, node, minetest.get_meta(pos))
			minetest.remove_node(pos)
			pos.y = pos.y + 1
			return nodecore.fallcheck(pos)
		end
	})
