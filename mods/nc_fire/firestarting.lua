-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore
    = ItemStack, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_craft({
		label = "stick fire starting",
		action = "pummel",
		wield = {
			groups = {firestick = true}
		},
		nodes = {
			{match = {groups = {firestick = true}}}
		},
		consumewield = 1,
		duration = 5,
		before = function(pos, rel, data)
			local w = data.wield and ItemStack(data.wield):get_name() or ""
			local wd = minetest.registered_items[w] or {}
			local wg = wd.groups or {}
			local fs = wg.firestick or 1
			local nd = minetest.registered_items[data.node.name] or {}
			local ng = nd.groups or {}
			fs = fs * (ng.firestick or 1)

			if math_random(1, 4) > fs then return end
			minetest.set_node(pos, {name = "nc_fire:fire"})

			if math_random(1, 4) > fs then return end
			local dir = nodecore.pickrand(nodecore.dirs())
			return nodecore.fire_check_ignite({
					x = pos.x + dir.x,
					y = pos.y + dir.y,
					z = pos.z + dir.z
				})
		end
	})
