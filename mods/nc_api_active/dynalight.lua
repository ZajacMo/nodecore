-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, setmetatable, vector
    = ItemStack, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

-- Register nodes that can be replaced by dynamic lights

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

-- Register dynamic light nodes

local nodes = {}

local function dynamic_light_node(level) return modname .. ":light" .. level end
nodecore.dynamic_light_node = dynamic_light_node

for level = 1, nodecore.light_sun - 1 do
	if nodes[level] then return nodes[level] end
	local name = dynamic_light_node(level)
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

minetest.register_alias("nc_torch:wield_light", dynamic_light_node(8))

-- API for adding dynamic lights to world

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

local function dynamic_light_add(pos, level, ttl)
	local name = minetest.get_node(pos).name
	if not canreplace[name] then return end
	if level < 1 then return end
	if level > nodecore.light_sun - 1 then level = nodecore.light_sun - 1 end
	local setname = dynamic_light_node(level)
	pos = vector.round(pos)
	local ll = nodecore.get_node_light(pos)
	if ll and ll > level then return end
	if name ~= setname then minetest.set_node(pos, {name = setname}) end
	active_lights[minetest.hash_node_position(pos)] = nodecore.gametime
	return minetest.get_node_timer(pos):start(ttl)
end
nodecore.dynamic_light_add = dynamic_light_add

-- Automatic player wield lights

local function lightsrc(stack)
	local def = minetest.registered_items[stack:get_name()] or {}
	return def.light_source or 0
end

local function player_wield_light(player)
	local glow = nodecore.scaling_light_level or 0
	for _, stack in pairs(player:get_inventory():get_list("main")) do
		local src = lightsrc(stack)
		if src > glow then glow = src end
	end
	if glow < 1 then return end
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	return dynamic_light_add(pos, glow, 0.5)
end

minetest.register_globalstep(function()
		for _, player in pairs(minetest.get_connected_players()) do
			player_wield_light(player)
		end
	end)

-- Automatic entity light sources

local function entlight(self, ...)
	local stack = ItemStack(self.node and self.node.name or self.itemstring or "")
	local src = lightsrc(stack)
	if src > 0 then nodecore.dynamic_light_add(self.object:get_pos(), src, 0.5) end
	return ...
end
for _, name in pairs({"item", "falling_node"}) do
	local def = minetest.registered_entities["__builtin:" .. name]
	local ndef = {
		on_step = function(self, ...)
			return entlight(self, def.on_step(self, ...))
		end
	}
	setmetatable(ndef, def)
	minetest.register_entity(":__builtin:" .. name, ndef)
end
