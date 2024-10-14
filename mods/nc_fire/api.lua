-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, ipairs, math, nc, pairs, string, tonumber, type,
      vector
    = ItemStack, core, ipairs, math, nc, pairs, string, tonumber, type,
      vector
local math_floor, math_pow, math_random, string_format
    = math.floor, math.pow, math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.fire_max = 8

do
	local flamedirs = nc.dirs()
	local ventitems = {}
	core.after(0, function()
			for k, v in pairs(core.registered_items) do
				if v.groups.flammable and not v.groups.fire_fuel
				and not v.on_ignite or v.groups.flame or v.name == "air" then
					ventitems[k] = v.groups.flame or 0
				end
			end
		end)
	local stackonly = {}
	core.after(0, function()
			for k, v in pairs(core.registered_items) do
				if v.groups.is_stack_only then
					stackonly[k] = true
				end
			end
		end)
	function nc.fire_vents(pos)
		local found = {}
		for _, dp in ipairs(flamedirs) do
			local npos = vector.add(pos, dp)
			local node = core.get_node_or_nil(npos)
			if not node then return end

			local q
			if stackonly[node.name] then
				q = ventitems[nc.stack_get(npos):get_name()]
			else
				q = ventitems[node.name]
			end
			if q then
				npos.q = q
				found[#found + 1] = npos
			end
		end
		return found
	end
end

local function burneject(pos, stack)
	if not stack then return end
	if type(stack) == "table" then
		for _, v in pairs(stack) do
			burneject(pos, v)
		end
		return
	end
	if type(stack) == "string" then stack = ItemStack(stack) end
	if not stack.is_empty then return end
	if stack and (not stack:is_empty()) then
		local p = nc.scan_flood(pos, 2, nc.buildable_to)
		nc.item_eject(p or pos, stack, 1)
	end
end

function nc.fire_ignite(pos, node)
	if nc.fire_quell then return end
	node = node or core.get_node(pos)
	nc.log("action", string_format("ignite %s at %s", node.name,
			core.pos_to_string(pos)))
	local def = core.registered_items[node.name]
	if def and def.on_ignite then
		local ign = def.on_ignite
		if type(ign) == "function" then
			ign = ign(pos, node)
			if ign == true then return true end
		end
		burneject(pos, ign)
	end
	if node and node.count and node.count > 1 then
		nc.item_disperse(pos, node.name, node.count - 1)
	end

	local fuel = nc.node_group("fire_fuel", pos, node) or 0
	if fuel < 0 then fuel = 0 end
	if fuel > nc.fire_max then fuel = nc.fire_max end
	fuel = math_floor(fuel)
	if fuel > 0 then
		nc.set_node_check(pos, {name = modname .. ":ember" .. fuel})
	else
		nc.set_node_check(pos, {name = modname .. ":fire_burst"})
	end

	nc.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
	nc.sound_play("nc_fire_flamy", {gain = 3, pos = pos})
	nc.fallcheck(pos)
	return true
end

function nc.fire_on_ignite_plantlike_rooted(replace)
	if nc.fire_quell then return end
	if type(replace) == "string" then replace = {name = replace} end
	return function(pos)
		core.set_node(pos, replace)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		nc.fire_ignite(above)
		return true
	end
end

function nc.fire_check_ignite(pos, node, force, ...)
	if nc.fire_quell then return end

	if not force then
		node = node or core.get_node(pos)
		local def = core.registered_items[node.name] or {}
		local flam = def.groups and def.groups.flammable
		if not flam then return end
		if math_random(1, flam) ~= 1 then return end
	end

	local vents = nc.fire_vents(pos)
	if (not vents) or #vents < 1 then return end

	if nc.quenched(pos) then return end

	return nc.fire_ignite(pos, node, ...)
end

local function snuff(cons, coal, pos, node, ember)
	ember = ember or nc.node_group("ember", pos, node)
	if not ember then return end
	ember = ember - cons
	if ember > 0 then
		if coal then
			nc.set_node_check(pos, {name = modname .. ":coal" .. ember})
			nc.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
		else
			nc.set_node_check(pos, {name = modname .. ":ember" .. ember})
		end
	else
		nc.set_node_check(pos, {name = modname .. ":ash"})
		nc.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
	end
	nc.fallcheck(pos)
	return true
end

function nc.fire_snuff(...) return snuff(1, true, ...) end
function nc.fire_expend(...) return snuff(1, false, ...) end

function nc.fire_check_expend(pos, node)
	local ember = nc.node_group("ember", pos, node)
	if not ember then return end
	local r = math_random(1, 16 * math_pow(2, ember))
	if r == 1 then return nc.fire_expend(pos, node, ember) end
end

local function snuffcheck(pos, node)
	if nc.fire_quell or nc.quenched(pos) then return true end
	local vents = nc.fire_vents(pos, node)
	if not vents then return end
	if #vents < 1 then return true end
	return false, vents
end

function nc.fire_check_snuff(pos, node)
	local res, vents = snuffcheck(pos, node)
	res = res and nc.fire_snuff(pos)
	return res, vents
end

core.register_chatcommand("ignite", {
		description = "Set fire to all nearby flammables",
		privs = {server = true},
		params = "[radius]",
		func = function(pname, param)
			local player = core.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			param = tonumber(param) or 5
			if param < 0 then param = 0 end
			if param > 79 then param = 79 end
			for _, p in pairs(nc.find_nodes_around(pos, "group:flammable", param)) do
				nc.fire_check_ignite(p, nil, true)
			end
		end
	})
core.register_chatcommand("snuff", {
		description = "Extinguish all nearby embers",
		privs = {server = true},
		params = "[radius]",
		func = function(pname, param)
			local player = core.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			param = tonumber(param) or 5
			if param < 0 then param = 0 end
			if param > 79 then param = 79 end
			for _, p in pairs(nc.find_nodes_around(pos, "group:ember", param)) do
				snuff(0, true, p)
			end
			for _, p in pairs(nc.find_nodes_around(pos, modname .. ":fire", 5)) do
				core.remove_node(p)
			end
		end
	})
