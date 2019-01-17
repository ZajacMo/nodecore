-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
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
			shafty = 1,
			snappy = 2,
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
	function nodecore.register_stick_fire_starting(name)
		nodecore.extend_pummel(name,
			function(pos, node, stats)
				return nodecore.wieldgroup(stats.puncher, "shafty")
			end,
			function(pos, node, stats)
				if not stats.wearout or not stats.ignite then
					node = node or minetest.get_node(pos)
					local def = minetest.registered_nodes[node.name]
					local shafty = def and def.groups and def.groups.shafty
					shafty = shafty * nodecore.wieldgroup(stats.puncher,
						"shafty")
					if shafty < 1 then return end
					stats.wearout = (1 + math_random()) * shafty
					stats.ignite = math_random() * 5
					if stats.ignite < stats.wearout then
						stats.wearout = stats.ignite
					end
					minetest.log("firesticks: " .. stats.wearout .. " | "
						.. stats.ignite)
				end
				if stats.duration < stats.wearout then return end
				if stats.duration >= stats.ignite then
					local dir = nodecore.pickrand(nodecore.dirs())
					local below = {
						x = pos.x + dir.x,
						y = pos.y + dir.y,
						z = pos.z + dir.z
					}
					if nodecore.node_is(below,
						{groups = {flammable = 1}}) then
						nodecore.ignite(below)
					end
					minetest.set_node(pos, {name = "nc_fire:fire"})
				end
				nodecore.wear_current_tool(stats.puncher, {shafty = 1}, 1)
			end)
	end
	nodecore.register_stick_fire_starting(modname .. ":stick")
end
