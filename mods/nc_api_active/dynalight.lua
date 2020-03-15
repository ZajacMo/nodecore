-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local nodes = {}
local canreplace = {air = true}

function nodecore.dynamic_light_node(level)
	level = math_floor(level)
	if level < 1 then level = 1 end
	if level > nodecore.light_sun - 1 then level = nodecore.light_sun - 1 end
	if nodes[level] then return nodes[level] end
	local name = modname .. ":light" .. level
	minetest.register_node(":" .. name, {
			drawtype = "airlike",
			paramtype = "light",
			light_source = level,
			pointable = false,
			walkable = false,
			on_timer = minetest.remove_node,
			groups = {dynamic_light = level}
		})
	nodes[level] = name
	canreplace[name] = true
	return name
end

minetest.register_alias("nc_torch:wield_light", nodecore.dynamic_light_node(8))

local active_lights = {}

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
