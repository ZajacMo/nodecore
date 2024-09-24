-- LUALOCALS < ---------------------------------------------------------
local nodecore, vector
    = nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local repeat_count = 4
local max_depth = 5

local cache = {}

local oldapply = nodecore.scaling_apply
function nodecore.scaling_apply(pointed, player, ...)
	if not player then return oldapply(pointed, player, ...) end
	local pname = player.get_player_name and player:get_player_name()
	local found = cache[pname]
	local qty = (found and vector.equals(found.above, pointed.above)
		and vector.equals(found.under, pointed.under) and found.qty or 0) + 1
	if qty < repeat_count then
		cache[pname] = {
			above = pointed.above,
			under = pointed.under,
			qty = qty
		}
		return oldapply(pointed, player, ...)
	end
	cache[pname] = nil
	nodecore.inventory_dump(player)
	nodecore.setphealth(player, 0)
	local dir = vector.subtract(pointed.under, pointed.above)
	local pos = vector.add(pointed.under, dir)
	for _ = 1, max_depth - 1 do
		local below = vector.offset(pos, 0, -1, 0)
		if nodecore.room_for_player(below) then
			return player:set_pos(below)
		end
		if nodecore.room_for_player(pos) then
			return player:set_pos(pos)
		end
		pos = vector.add(pos, dir)
	end
	return player:set_pos(vector.offset(pos, 0, -1, 0))
end
