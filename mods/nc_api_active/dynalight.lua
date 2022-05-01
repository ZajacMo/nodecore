-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, setmetatable, vector
    = ItemStack, minetest, nodecore, pairs, setmetatable, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

-- Register nodes that can be replaced by dynamic lights

local canreplace = {air = 0}

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
			if ok then canreplace[k] = 0 end
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
	nodecore.dnt_set(pos, modname .. ":dynalight_check")
end

local function check_light(pos)
	local data = active_lights[minetest.hash_node_position(pos)]
	if not data then return minetest.remove_node(pos) end
	if nodecore.gametime < data.exp then return end
	if data.check and data.check() then
		data.exp = nodecore.gametime + ttl
		nodecore.dnt_set(pos, modname .. ":dynalight_check")
		return
	end
	minetest.remove_node(pos)
	return true
end

nodecore.register_dnt({
		name = modname .. ":dynalight_check",
		nodenames = {"group:dynamic_light"},
		ignore_stasis = true,
		time = ttl,
		autostart = true,
		autostart_time = 0,
		action = check_light
	})

-- Register dynamic light nodes

local function dynamic_light_node(level) return modname .. ":light" .. level end
nodecore.dynamic_light_node = dynamic_light_node

for level = 1, nodecore.light_sun - 1 do
	local name = dynamic_light_node(level)
	local def = {
		description = minetest.registered_nodes.air.description,
		light_source = level,
		air_equivalent = true,
		groups = {dynamic_light = level}
	}
	for k, v in pairs(true_airlike) do def[k] = def[k] or v end
	minetest.register_node(":" .. name, def)
	canreplace[name] = level
end

minetest.register_alias("nc_torch:wield_light", dynamic_light_node(8))

-- API for adding dynamic lights to world

local function dynamic_light_add(pos, level, check, exact)
	if not pos then return end
	local name = minetest.get_node(pos).name
	local curlight = canreplace[name]
	if not curlight then
		if exact then return end
		return dynamic_light_add({x = pos.x, y = pos.y - 1, z = pos.z}, level, check, true)
		or dynamic_light_add({x = pos.x, y = pos.y + 1, z = pos.z}, level, check, true)
		or dynamic_light_add({x = pos.x + 1, y = pos.y, z = pos.z}, level, check, true)
		or dynamic_light_add({x = pos.x - 1, y = pos.y, z = pos.z}, level, check, true)
		or dynamic_light_add({x = pos.x, y = pos.y, z = pos.z + 1}, level, check, true)
		or dynamic_light_add({x = pos.x, y = pos.y, z = pos.z - 1}, level, check, true)
	end
	if level < 1 then return end
	if level > nodecore.light_sun - 1 then level = nodecore.light_sun - 1 end
	local setname = dynamic_light_node(level)
	pos = vector.round(pos)
	if curlight <= level then
		local ll = nodecore.get_node_light(pos)
		if ll and ll > level then return end
	end
	if curlight > level and not check_light(pos) then return end
	if name ~= setname then minetest.set_node(pos, {name = setname}) end
	setup_light(pos, check)
	return true
end
nodecore.dynamic_light_add = dynamic_light_add

-- Automatic player wield lights

local function lightsrc(stack)
	local def = minetest.registered_items[stack:get_name()] or {}
	return def.light_source or 0
end

local function player_wield_light(player)
	local glow = 0
	local srcidx, srcstack
	for idx, stack in pairs(player:get_inventory():get_list("main")) do
		local src = lightsrc(stack)
		if src > glow then
			glow = src
			srcidx = idx
			srcstack = stack:get_name()
		end
	end
	if glow < 1 then return end
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	pos = vector.round(pos)
	local pname = player:get_player_name()
	return dynamic_light_add(pos, glow, function()
			local pl = minetest.get_player_by_name(pname)
			if not pl then return end
			local pp = pl:get_pos()
			pp.y = pp.y + pl:get_properties().eye_height
			if not vector.equals(pos, vector.round(pp)) then return end
			return pl:get_inventory():get_stack("main", srcidx)
			:get_name() == srcstack
		end)
end

nodecore.register_playerstep({
		label = "player wield light",
		action = function(player)
			if nodecore.player_visible(player) then
				return player_wield_light(player)
			end
		end
	})

-- Automatic entity light sources

local function entlight(self, ...)
	local stack = ItemStack(self.node and self.node.name or self.itemstring or "")
	local src = lightsrc(stack)
	if src > 0 then
		local pos = self.object:get_pos()
		if not pos then return ... end
		pos = vector.round(pos)
		nodecore.dynamic_light_add(pos, src, function()
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
