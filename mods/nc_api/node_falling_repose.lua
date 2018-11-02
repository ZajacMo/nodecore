local minetest = minetest
local nodecore = nodecore

nodecore.register_on_register_node(function(name, def)
		def.groups = def.groups or {}

		if def.groups.falling_repose then def.groups.falling_node = 1 end

		def.repose_drop = def.repose_drop or function(posfrom, posto, node)
			minetest.spawn_falling_node(posto, node, minetest.get_meta(posfrom))
			minetest.remove_node(posfrom)
			posfrom.y = posfrom.y + 1
			return minetest.check_for_falling(posfrom)
		end
	end)

function minetest.spawn_falling_node(pos, node, meta)
	node = node or minetest.get_node(pos)
	if node.name == "air" or node.name == "ignore" then
		return false
	end
	local obj = minetest.add_entity(pos, "__builtin:falling_node")
	if obj then
		obj:get_luaentity():set_node(node, meta or minetest.get_meta(pos):to_table())
		minetest.remove_node(pos)
		return true
	end
	return false
end

local function check_empty(pos, dx, dy, dz)
	for ndy = dy, 1 do
		local p = {x = pos.x + dx, y = pos.y + ndy, z = pos.z + dz}
		local node = minetest.get_node(p)
		if not minetest.registered_nodes[node.name].buildable_to then return end
	end
	return {x = pos.x + dx, y = pos.y, z = pos.z + dz}
end
local function repose_transform(pos, node)
	if minetest.check_single_for_falling(pos) then return end
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local repose = def.groups.falling_repose
	local open = {}
	local ok = check_empty(pos, 1, -repose, 0)
	if ok then open[1] = ok end
	ok = check_empty(pos, -1, -repose, 0)
	if ok then open[#open + 1] = ok end
	ok = check_empty(pos, 0, -repose, 1)
	if ok then open[#open + 1] = ok end
	ok = check_empty(pos, 0, -repose, -1)
	if ok then open[#open + 1] = ok end
	if #open < 1 then return end
	return def.repose_drop(pos, open[math.random(1, #open)], node)
end

local reposeq
local qqty
local qmax = 100
local function reposeall()
	for _, v in pairs(reposeq) do v() end
	reposeq = nil
	qqty = nil
end
minetest.register_abm({
		label = "Falling Material Repose",
		nodenames = {"group:falling_repose"},
		neighbors = {"air"},
		interval = 2,
		chance = 5,
		action = function(pos, node)
			if not reposeq then
				reposeq = {}
				qqty = 0
				minetest.after(0, reposeall)
			end
			local f = function() repose_transform(pos, node) end
			if #reposeq > qmax then
				local i = math.random(1, qqty)
				if i < qmax then reposeq[i] = f end
			else
				reposeq[#reposeq + 1] = f
			end
			qqty = qqty + 1
		end
	})