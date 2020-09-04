-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

nodecore.register_globalstep("scaling", function()
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

	local node = minetest.get_node(pointed.under)
	local def = minetest.registered_nodes[node.name]
	local groups = def and def.groups or {}
	if not player:get_player_control().sneak and def and def.on_rightclick
	and not groups.always_scalable then
		return minetest.item_place(stack, player, pointed, ...)
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

	local timecost = (pointed.under.y > pointed.above.y) and 5 or 3
	if groups.scaling_time then
		timecost = timecost * groups.scaling_time / 100
	else
		if def.climbable then timecost = timecost * 0.25 end
		if groups.cobbley then timecost = timecost * 0.75 end
		if groups.falling_node then timecost = timecost * 1.2 end
	end
	if now < stats.start + timecost then
		if now >= stats.start + 1 then
			nodecore.dynamic_light_add(pointed.above,
				nodecore.scaling_light_level,
				function()
					player = minetest.get_player_by_name(pname)
					return player and nodecore.scaling_closenough(
						pointed.above, player)
				end)
		end
		return
	end

	cache[pname] = nil

	if def and def.on_scaling and def.on_scaling(stats,
		stack, player, pointed, node, ...) then return end

	if nodecore.scaling_apply(pointed, player) then
		nodecore.player_discover(player, "craft:scaling dy="
			.. (pointed.under.y - pointed.above.y))
		return nodecore.scaling_particles(pointed.above, {
				time = 0.1,
				amount = 40,
				minexptime = 0.02
			})
	end
end
minetest.register_item(":", hand)
