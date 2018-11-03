-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes with the "falling_repose" group will not only fall if unsupported
from below, but if there is a sufficient drop off the sides, so simulate
an "angle of repose."
--]]

function nodecore.falling_repose_drop(posfrom, posto, node)
	minetest.spawn_falling_node(posto, node, minetest.get_meta(posfrom))
	minetest.remove_node(posfrom)
	posfrom.y = posfrom.y + 1
	return minetest.check_for_falling(posfrom)
end

nodecore.register_on_register_node(function(name, def)
		def.groups = def.groups or {}

		if def.groups.falling_repose then def.groups.falling_node = 1 end

		def.repose_drop = def.repose_drop or nodecore.falling_repose_drop
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
function nodecore.falling_repose_check(pos)
	if minetest.check_single_for_falling(pos) then return end
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local repose = def.groups.falling_repose
	if not repose then return end

	-- Reposing nodes can always sit comfortably atop
	-- a non-moving node; it's only when stacked on other
	-- falling nodes that they can slip off.
	if not (minetest.registered_nodes[minetest.get_node(
			{x = pos.x, y = pos.y - 1, z = pos.z}).name].groups
		or {}).falling_node
	then return end

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
	return def.repose_drop(pos, open[math_random(1, #open)], node)
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
		label = "Falling Repose",
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
			local f = function() nodecore.falling_repose_check(pos) end
			if #reposeq > qmax then
				local i = math_random(1, qqty)
				if i < qmax then reposeq[i] = f end
			else
				reposeq[#reposeq + 1] = f
			end
			qqty = qqty + 1
		end
	})
