-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

local droppingall = {}
local function dropall(pname, matching)
	local player = core.get_player_by_name(pname)
	if not player then return end
	local pos = player:get_pos()
	droppingall[pname] = true
	local inv = player:get_inventory()
	for i = 1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if not (stack:is_empty() or nc.item_is_virtual(stack)
			or matching and nc.stack_family(stack) ~= matching) then
			stack = core.item_drop(stack, player, pos)
			inv:set_stack("main", i, stack)
		end
	end
	droppingall[pname] = nil
end

local olddrop = core.item_drop
function core.item_drop(item, player, ...)
	if not (player and player:is_player()) then
		return olddrop(item, player, ...)
	end
	nc.player_discover(player, "item_drop")
	local pctl = player:get_player_control()
	if pctl.aux1 then
		nc.player_discover(player, "aux_item_drop")
		local pname = player:get_player_name()
		if not droppingall[pname] then
			core.after(0, dropall, pname,
				pctl.sneak and nc.stack_family(player:get_wielded_item()))
		end
		if droppingall[player:get_player_name()] then
			return olddrop(item, player, ...)
		end
	else
		return olddrop(item, player, ...)
	end
end
