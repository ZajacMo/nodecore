-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.ignite(pos, node)
	local fuel = nodecore.node_group("fire_fuel", pos, node) or 0
	if fuel < 0 then fuel = 0 end
	if fuel > 6 then fuel = 6 end
	fuel = math_floor(fuel)
	local stack
	if nodecore.node_group("eject_inv_on_burn", pos, node) then
		stack = nodecore.stack_get(pos)
		if stack and (not stack:is_empty()) then
			local p = nodecore.scan_flood(pos, 2, nodecore.buildable_to)
			nodecore.item_eject(p or pos, stack, 1)
		end
	end
	if fuel > 0 then
		minetest.set_node(pos, {name = modname .. ":ember" .. fuel})
		minetest.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
		minetest.sound_play("nc_fire_flamy", {gain = 3, pos = pos})
	else
		minetest.set_node(pos, {name = modname .. ":fire"})
	end
	minetest.after(0, function() minetest.check_for_falling(pos) end)
end

function nodecore.snuff(pos, node, groups)
	local ember = nodecore.node_group("ember", pos, node)
	if not ember then return end
	ember = ember - 1
	if ember > 0 then
		minetest.set_node(pos, {name = modname .. ":ember" .. ember})
	else
		minetest.set_node(pos, {name = modname .. ":ash"})
		minetest.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
	end
	minetest.after(0, function() minetest.check_for_falling(pos) end)
end
