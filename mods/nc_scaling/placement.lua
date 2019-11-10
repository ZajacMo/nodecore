-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

minetest.register_globalstep(function()
		local keep = {}
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			keep[pname] = player:get_wielded_item():is_empty()
			and not player:get_player_control().LMB
		end
		for k in pairs(cache) do
			if not keep[k] then cache[k] = nil end
		end
	end)

local hand = {}
for k, v in pairs(minetest.registered_items[""]) do hand[k] = v end
hand.on_place = function(stack, player, pointed, ...)
	if pointed.type ~= "node" then return minetest.item_place(stack, player, pointed, ...) end

	local pname = player and player.get_player_name and player:get_player_name()
	if not pname then return minetest.item_place(stack, player, pointed, ...) end

	if not player:get_player_control().sneak then
		local node = minetest.get_node(pointed.under)
		local def = minetest.registered_nodes[node.name]
		if def and def.on_rightclick then
			return minetest.item_place(stack, player, pointed, ...)
		end
	end

	local now = minetest.get_us_time() / 1000000
	local resetto = {
		pointed = pointed,
		start = now,
		last = now
	}
	local stats = cache[pname] or resetto
	if stats.last < (now - 2)
	or (not vector.equals(stats.pointed.under, pointed.under))
	or (not vector.equals(stats.pointed.above, pointed.above))
	then stats = resetto else stats.last = now end
	cache[pname] = stats

	local finish = stats.start + 3
	if pointed.under.y > pointed.above.y then finish = stats.start + 5 end
	if now < finish then return end

	cache[pname] = nil
	if nodecore.scaling_apply(pointed) then
		return nodecore.scaling_particles(pointed.above, {
				time = 0.1,
				amount = 40,
				minexptime = 0.02
			})
	end
end
minetest.register_item(":", hand)
