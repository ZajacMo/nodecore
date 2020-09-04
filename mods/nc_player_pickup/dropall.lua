-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local droppingall = {}
local function dropall(pname, pos, matching)
	local player = minetest.get_player_by_name(pname)
	if not player then return end
	if droppingall[pname] then return end
	droppingall[pname] = true
	local inv = player:get_inventory()
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not (stack:is_empty() or nodecore.item_is_virtual(stack)
			or matching and stack:get_name() ~= matching) then
			stack = minetest.item_drop(stack, player, pos)
			inv:set_stack("main", i, stack)
		end
	end
	droppingall[pname] = nil
end

local olddrop = minetest.item_drop
function minetest.item_drop(item, player, ...)
	local pctl = player:get_player_control()
	if pctl.aux1 then
		local pname = player:get_player_name()
		minetest.after(0, dropall, pname, player:get_pos(),
			pctl.sneak and player:get_wielded_item():get_name())
	end
	return olddrop(item, player, ...)
end
