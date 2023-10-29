-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

function nodecore.spin_filter_facedirs(func)
	local allowed = {}
	local equiv = {}
	for i = 0, 23 do
		local f = nodecore.facedirs[i]
		local hit
		for j = 1, #allowed do
			if not hit then
				local o = nodecore.facedirs[allowed[j]]
				hit = func(f, o)
				if hit then equiv[i] = allowed[j] end
			end
		end
		if not hit then
			allowed[#allowed + 1] = i
			equiv[i] = i
		end
	end

	allowed[0] = false
	local cycle = {}
	for i = 1, #allowed do
		cycle[allowed[i - 1]] = allowed[i]
	end
	cycle[allowed[#allowed]] = allowed[1]

	return {
		qty = #allowed,
		cycle = cycle,
		equiv = equiv
	}
end

function nodecore.spin_node_cycle(pos, node, clicker, itemstack)
	if nodecore.protection_test(pos, clicker) then return end
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	local data = def.spindata
	if not data then return end
	node.param2 = data.cycle[node.param2] or data.cycle[false]
	if clicker:is_player() then
		nodecore.log("action", clicker:get_player_name() .. " spins "
			.. node.name .. " at " .. minetest.pos_to_string(pos)
			.. " to param2 " .. node.param2 .. " ("
			.. data.qty .. " total)")
	end
	minetest.swap_node(pos, node)
	nodecore.node_sound(pos, "place")
	if def.on_spin then def.on_spin(pos, node) end
	return itemstack
end
