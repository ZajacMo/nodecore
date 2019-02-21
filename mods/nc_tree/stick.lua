-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore
    = ItemStack, math, minetest, nodecore
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":stick", {
		description = "Stick",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-1/16, -0.5, -1/16, 1/16, 0, 1/16),
		tiles = {
			modname .. "_tree_top.png",
			modname .. "_tree_top.png",
			modname .. "_tree_side.png"
		},
		paramtype = "light",
		groups = {
			firestick = 1,
			snappy = 1,
			flammable = 2,
			falling_repose = 1
		}
	})

nodecore.register_leaf_drops(function(pos, node, list)
		list[#list + 1] = {
			name = modname .. ":stick",
			prob = 0.2 * (node.param2 * node.param2)}
	end)

if nodecore.loaded_mods().nc_fire then
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
				local below = {
					x = pos.x + dir.x,
					y = pos.y + dir.y,
					z = pos.z + dir.z
				}
				if nodecore.match(below,
					{groups = {flammable = 1}}) then
					nodecore.ignite(below)
				end
			end
		})
end
