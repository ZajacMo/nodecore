-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, pairs, type, vector
    = ItemStack, ipairs, math, minetest, nodecore, pairs, type, vector
local math_floor, math_pow, math_random
    = math.floor, math.pow, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.fire_max = 8

do
	local flamedirs = nodecore.dirs()
	local ventitems = {}
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_items) do
				if v.groups.flammable and not v.groups.fire_fuel
				and not v.on_ignite or v.groups.flame or v.name == "air" then
					ventitems[k] = v.groups.flame or 0
				end
			end
		end)
	local stackonly = {}
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_items) do
				if v.groups.is_stack_only then
					stackonly[k] = true
				end
			end
		end)
	function nodecore.fire_vents(pos)
		local found = {}
		for _, dp in ipairs(flamedirs) do
			local npos = vector.add(pos, dp)
			local node = minetest.get_node_or_nil(npos)
			if not node then return end

			local q
			if stackonly[node.name] then
				q = ventitems[nodecore.stack_get(npos):get_name()]
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
		local p = nodecore.scan_flood(pos, 2, nodecore.buildable_to)
		nodecore.item_eject(p or pos, stack, 1)
	end
end

function nodecore.fire_ignite(pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	if def and def.on_ignite then
		local ign = def.on_ignite
		if type(ign) == "function" then
			ign = ign(pos, node)
			if ign == true then return end
		end
		burneject(pos, ign)
	end
	if node and node.count and node.count > 1 then
		nodecore.item_disperse(pos, node.name, node.count - 1)
	end

	local fuel = nodecore.node_group("fire_fuel", pos, node) or 0
	if fuel < 0 then fuel = 0 end
	if fuel > nodecore.fire_max then fuel = nodecore.fire_max end
	fuel = math_floor(fuel)
	if fuel > 0 then
		minetest.set_node(pos, {name = modname .. ":ember" .. fuel})
	else
		minetest.set_node(pos, {name = modname .. ":fire"})
	end

	nodecore.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
	nodecore.sound_play("nc_fire_flamy", {gain = 3, pos = pos})
	nodecore.fallcheck(pos)
	return true
end

function nodecore.fire_check_ignite(pos, node, force, ...)
	if not force then
		node = node or minetest.get_node(pos)
		local def = minetest.registered_items[node.name] or {}
		local flam = def.groups and def.groups.flammable
		if not flam then return end
		if math_random(1, flam) ~= 1 then return end
	end

	local vents = nodecore.fire_vents(pos)
	if (not vents) or #vents < 1 then return end

	if nodecore.quenched(pos) then return end

	return nodecore.fire_ignite(pos, node, ...)
end

local function snuff(cons, coal, pos, node, ember)
	ember = ember or nodecore.node_group("ember", pos, node)
	if not ember then return end
	ember = ember - cons
	if ember > 0 then
		if coal then
			minetest.set_node(pos, {name = modname .. ":coal" .. ember})
			nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
		else
			minetest.set_node(pos, {name = modname .. ":ember" .. ember})
		end
	else
		minetest.set_node(pos, {name = modname .. ":ash"})
		nodecore.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
	end
	nodecore.fallcheck(pos)
	return true
end

function nodecore.fire_snuff(...) return snuff(1, true, ...) end
function nodecore.fire_expend(...) return snuff(1, false, ...) end

function nodecore.fire_check_expend(pos, node)
	local ember = nodecore.node_group("ember", pos, node)
	if not ember then return end
	local r = math_random(1, 16 * math_pow(2, ember))
	if r == 1 then return nodecore.fire_expend(pos, node, ember) end
end

local function snuffcheck(pos, node)
	if nodecore.quenched(pos) then return true end
	local vents = nodecore.fire_vents(pos, node)
	if not vents then return end
	if #vents < 1 then return true end
	return false, vents
end

function nodecore.fire_check_snuff(pos, node)
	local res, vents = snuffcheck(pos, node)
	res = res and nodecore.fire_snuff(pos)
	return res, vents
end

minetest.register_chatcommand("ignite", {
		description = "Set fire to all nearby flammables",
		privs = {["debug"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:flammable", 5)) do
				nodecore.fire_check_ignite(p, nil, true)
			end
		end
	})
minetest.register_chatcommand("snuff", {
		description = "Extinguish all nearby embers",
		privs = {["debug"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local pos = player:get_pos()
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:ember", 5)) do
				snuff(0, true, p)
			end
			for _, p in pairs(nodecore.find_nodes_around(pos, modname .. ":fire", 5)) do
				minetest.remove_node(p)
			end
		end
	})
