-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local nodes = {}
local canreplace = {air = true}

local true_airlike = {
	drawtype = "airlike",
	pointable = false,
	walkable = false,
	climbable = false,
	buildable_to = true,
	floodable = true,
	air_equivalent = true,
	paramtype = "light",
	light_source = 0,
	sunlight_propagates = true,
}

function nodecore.dynamic_light_node(level)
	level = math_floor(level)
	if level < 1 then level = 1 end
	if level > nodecore.light_sun - 1 then level = nodecore.light_sun - 1 end
	if nodes[level] then return nodes[level] end
	local name = modname .. ":light" .. level
	local def = {
		light_source = level,
		on_timer = minetest.remove_node,
		groups = {dynamic_light = level}
	}
	for k, v in pairs(true_airlike) do def[k] = def[k] or v end
	minetest.register_node(":" .. name, def)
	nodes[level] = name
	canreplace[name] = true
	return name
end

minetest.register_alias("nc_torch:wield_light", nodecore.dynamic_light_node(8))

local active_lights = {}

minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			local ok = not canreplace[k]
			for dk, dv in pairs(true_airlike) do
				ok = ok and v[dk] == dv
			end
			if ok then canreplace[k] = true end
		end
	end)

nodecore.register_limited_abm({
		label = "dynamic light cleanup",
		interval = 1,
		chance = 1,
		nodenames = {"group:dynamic_light"},
		action = function(pos)
			local time = active_lights[minetest.hash_node_position(pos)] or 0
			if time >= nodecore.gametime - 2 then return end
			minetest.log("dynalight cleaned up at " .. minetest.pos_to_string(pos))
			return minetest.remove_node(pos)
		end
	})

function nodecore.dynamic_light_add(pos, nodename, ttl)
	local name = minetest.get_node(pos).name
	if not canreplace[name] then return end
	if name ~= nodename then minetest.set_node(pos, {name = nodename}) end
	pos = vector.round(pos)
	active_lights[minetest.hash_node_position(pos)] = nodecore.gametime
	return minetest.get_node_timer(pos):start(ttl)
end
