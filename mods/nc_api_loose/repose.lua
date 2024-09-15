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
	nodecore.node_sound(posfrom, "fall")
	minetest.spawn_falling_node(posto, node, minetest.get_meta(posfrom))
	minetest.remove_node(posfrom)
	posfrom.y = posfrom.y + 1
	return nodecore.fallcheck(posfrom)
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end

		def.groups = def.groups or {}

		if def.groups.falling_repose then def.groups.falling_node = 1 end

		def.repose_drop = def.repose_drop or nodecore.falling_repose_drop
	end)

local function check_empty(pos, dx, dy, dz)
	for ndy = dy, 0 do
		local p = {x = pos.x + dx, y = pos.y + ndy, z = pos.z + dz}
		if not nodecore.buildable_to(p) then return end
	end
	return {x = pos.x + dx, y = pos.y, z = pos.z + dz}
end
function nodecore.falling_repose_positions(pos, node, def)
	node = node or minetest.get_node(pos)
	def = def or minetest.registered_items[node.name] or {}
	local repose = def.groups and def.groups.falling_repose
	if not repose then return end

	-- Reposing nodes can always sit comfortably atop
	-- a non-moving node; it's only when stacked on other
	-- falling nodes that they can slip off.
	local sitdef = minetest.registered_items[minetest.get_node(
		{x = pos.x, y = pos.y - 1, z = pos.z}).name]
	if not (sitdef and sitdef.groups and sitdef.groups.falling_node)
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
	return #open > 0 and open or nil, node, def
end
function nodecore.falling_repose_check(pos)
	if minetest.check_single_for_falling(pos) then return end
	local open, node, def = nodecore.falling_repose_positions(pos)
	if not open then return end
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
		label = "falling repose",
		nodenames = {"group:falling_repose"},
		neighbors = {"air"},
		interval = 2,
		chance = 5,
		arealoaded = 1,
		action = function(pos)
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
