-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, vector
    = core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

local tunnel_repeat_count = 3
local tunnel_max_time = 30

nc.register_globalstep(function()
		local keep = {}
		for _, player in pairs(core.get_connected_players()) do
			local pname = player:get_player_name()
			keep[pname] = player:get_wielded_item():is_empty()
			and not player:get_player_control().LMB
		end
		for k in pairs(cache) do
			if not keep[k] then cache[k] = nil end
		end
	end)

local hand = {}
for k, v in pairs(core.registered_items[""]) do hand[k] = v end
hand.on_place = function(stack, player, pointed, ...)
	if pointed.type ~= "node" then return core.item_place(stack, player, pointed, ...) end

	local pname = player and player.get_player_name and player:get_player_name()
	if not pname then return core.item_place(stack, player, pointed, ...) end

	local node = core.get_node(pointed.under)
	local def = core.registered_nodes[node.name]
	local groups = def and def.groups or {}
	if not player:get_player_control().sneak and def and def.on_rightclick
	and not groups.always_scalable then
		return core.item_place(stack, player, pointed, ...)
	end

	local now = core.get_us_time() / 1000000
	local resetto = {
		pointed = pointed,
		start = now,
		last = now,
		count = 0
	}
	local stats = cache[pname] or resetto
	if stats.last < (now - 2)
	or (not vector.equals(stats.pointed.under, pointed.under))
	or (not vector.equals(stats.pointed.above, pointed.above))
	then stats = resetto else stats.last = now end
	stats.tunnellimit = stats.tunnellimit or stats.start + tunnel_max_time
	cache[pname] = stats

	local timecost = (pointed.under.y > pointed.above.y) and 5 or 3
	if groups.scaling_time then
		timecost = timecost * groups.scaling_time / 100
	else
		if def and def.climbable then timecost = timecost * 0.25 end
		if groups.cobbley then timecost = timecost * 0.75 end
		if groups.falling_node then timecost = timecost * 1.2 end
	end
	local done = now >= stats.start + timecost

	if (done and stats.count >= tunnel_repeat_count) or now > stats.tunnellimit then
		cache[pname] = resetto
		return nc.scaling_tunnel(pointed, player)
	end

	if not done then
		if now >= stats.start + 1 then
			if nc.dynamic_light_add(pointed.above,
				nc.scaling_light_level,
				function()
					player = core.get_player_by_name(pname)
					return player and nc.scaling_closenough(
						pointed.above, player)
				end
			) then
				nc.player_discover(player, "craft:scaling light")
			end
		end
		return
	end

	resetto.count = stats.count + 1
	resetto.tunnellimit = stats.tunnellimit
	cache[pname] = resetto

	if def and def.on_scaling and def.on_scaling(stats,
		stack, player, pointed, node, ...) then return end

	if nc.scaling_apply(pointed, player) then
		nc.player_discover(player, "craft:scaling dy="
			.. (pointed.under.y - pointed.above.y))
		return nc.scaling_particles(pointed.above, {
				time = 0.1,
				amount = 40,
				minexptime = 0.02
			})
	end
end
core.register_item(":", hand)
