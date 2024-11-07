-- LUALOCALS < ---------------------------------------------------------
local core, nc, vector
    = core, nc, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local repeat_count = 4 -- +1 to place initial scaling node
local max_depth = 5

local cache = {}

local snodes = nc.group_expand("group:" .. modname, true)

local oldapply = nc.scaling_apply
function nc.scaling_apply(pointed, player, ...)
	if not player then return oldapply(pointed, player, ...) end
	local pname = player.get_player_name and player:get_player_name()
	if not snodes[core.get_node(pointed.above).name] then
		cache[pname] = nil
		return oldapply(pointed, player, ...)
	end
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
	nc.inventory_dump(player)
	nc.setphealth(player, 0)
	local dir = vector.subtract(pointed.under, pointed.above)
	local pos = vector.add(pointed.under, dir)
	for _ = 1, max_depth - 1 do
		local below = vector.offset(pos, 0, -1, 0)
		if nc.room_for_player(below) then
			return player:set_pos(below)
		end
		if nc.room_for_player(pos) then
			return player:set_pos(pos)
		end
		pos = vector.add(pos, dir)
	end
	return player:set_pos(vector.offset(pos, 0, -1, 0))
end
