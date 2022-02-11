-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local droppingall = {}
local function dropall(pname, matching)
	local player = minetest.get_player_by_name(pname)
	if not player then return end
	local pos = player:get_pos()
	droppingall[pname] = true
	local inv = player:get_inventory()
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not (stack:is_empty() or nodecore.item_is_virtual(stack)
			or matching and nodecore.stack_family(stack) ~= matching) then
			stack = minetest.item_drop(stack, player, pos)
			inv:set_stack("main", i, stack)
		end
	end
	droppingall[pname] = nil
end

local olddrop = minetest.item_drop
function minetest.item_drop(item, player, ...)
	nodecore.player_discover(player, "item_drop")
	local pctl = player:get_player_control()
	if pctl.aux1 then
		nodecore.player_discover(player, "aux_item_drop")
		local pname = player:get_player_name()
		if not droppingall[pname] then
			minetest.after(0, dropall, pname,
				pctl.sneak and nodecore.stack_family(player:get_wielded_item()))
		end
		if droppingall[player:get_player_name()] then
			return olddrop(item, player, ...)
		end
	else
		return olddrop(item, player, ...)
	end
end
