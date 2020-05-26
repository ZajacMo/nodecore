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

-- API for checking if dynamic lights are valid

local ttl = 0.25

local active_lights = {}

local function setup_light(pos, check)
	active_lights[minetest.hash_node_position(pos)] = {
		exp = nodecore.gametime + ttl,
		check = check
	}
	minetest.get_node_timer(pos):start(ttl)
end

local function check_light(pos)
	local data = active_lights[minetest.hash_node_position(pos)]
	if not data then return minetest.remove_node(pos) end
	if nodecore.gametime < data.exp then return end
	if data.check and data.check(pos) then
		data.exp = nodecore.gametime + ttl
		minetest.get_node_timer(pos):start(ttl)
		return
	end
	minetest.remove_node(pos)
	return true
end

-- Register dynamic light nodes

local nodes = {}

local function dynamic_light_node(level) return modname .. ":light" .. level end
nodecore.dynamic_light_node = dynamic_light_node

for level = 1, nodecore.light_sun - 1 do
	if nodes[level] then return nodes[level] end
	local name = dynamic_light_node(level)
	local def = {
		light_source = level,
		on_timer = check_light,
		groups = {dynamic_light = level}
	}
	for k, v in pairs(true_airlike) do def[k] = def[k] or v end
	minetest.register_node(":" .. name, def)
	nodes[level] = name
	canreplace[name] = true
end

minetest.register_alias("nc_torch:wield_light", dynamic_light_node(8))

-- API for adding dynamic lights to world

nodecore.register_limited_abm({
		label = "dynamic light cleanup",
		interval = 1,
		chance = 1,
		nodenames = {"group:dynamic_light"},
		action = check_light
	})

local function dynamic_light_add(pos, level, check)
	if not pos then return end
	local name = minetest.get_node(pos).name
	if not canreplace[name] then return end
	if level < 1 then return end
	if level > nodecore.light_sun - 1 then level = nodecore.light_sun - 1 end
	local setname = dynamic_light_node(level)
	pos = vector.round(pos)
	local ll = nodecore.get_node_light(pos)
	if ll and ll > level then return end
	if name ~= setname then minetest.set_node(pos, {name = setname}) end
	setup_light(pos, check)
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
	local pname = player:get_player_name()
	return dynamic_light_add(pos, glow, function(np)
			local pl = minetest.get_player_by_name(pname)
			if not pl then return end
			local pp = pl:get_pos()
			pp.y = pp.y + pl:get_properties().eye_height
			return vector.equals(vector.round(np), vector.round(pp))
		end)
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
	if src > 0 then
		nodecore.dynamic_light_add(self.object:get_pos(), src, function(pos)
				for _, v in pairs(nodecore.get_objects_at_pos(pos)) do
					if v == self.object then return true end
				end
			end)
	end
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
