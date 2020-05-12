-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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

minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			local ok = not canreplace[k]
			for dk, dv in pairs(true_airlike) do
				ok = ok and v[dk] == dv
			end
			if ok then canreplace[k] = true end
		end
	end)

local nodes = {}

local function nodename(level) return modname .. ":light" .. level end
nodecore.dynamic_light_node = nodename

for level = 1, nodecore.light_sun - 1 do
	if nodes[level] then return nodes[level] end
	local name = nodename(level)
	local def = {
		light_source = level,
		on_timer = minetest.remove_node,
		groups = {dynamic_light = level}
	}
	for k, v in pairs(true_airlike) do def[k] = def[k] or v end
	minetest.register_node(":" .. name, def)
	nodes[level] = name
	canreplace[name] = true
end

minetest.register_alias("nc_torch:wield_light", nodename(8))

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

function nodecore.dynamic_light_add(pos, level, ttl)
	local name = minetest.get_node(pos).name
	if not canreplace[name] then return end
	local setname = nodename(level)
	pos = vector.round(pos)
	if name ~= setname then minetest.set_node(pos, {name = setname}) end
	active_lights[minetest.hash_node_position(pos)] = nodecore.gametime
	return minetest.get_node_timer(pos):start(ttl)
end
