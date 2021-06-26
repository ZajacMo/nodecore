-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs
    = ItemStack, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local nodename = modname .. ":displaced"
minetest.register_node(nodename, {
		description = "Displaced Node",
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		climbable = true,
		groups = {
			visinv = 1,
			[modname .. "_fx"] = 1,
			support_falling = 1
		},
		light_source = 1,
	})

local olddig = minetest.node_dig
function minetest.node_dig(pos, node, digger, ...)
	local def = node and node.name and minetest.registered_nodes[node.name]
	if def and def.diggable ~= false then
		local tool = digger and digger:is_player()
		and digger:get_wielded_item()

		if (not tool) or nodecore.tool_digs(tool, def.groups) then
			return olddig(pos, node, digger, ...)
		end

		local mock = ItemStack(node.name)
		mock:set_count(def.stack_max or 99)

		local stack = nodecore.stack_get(pos)
		nodecore.stack_set(pos, "")

		minetest.set_node(pos, {name = nodename})
		nodecore.stack_set(pos, mock)
		local meta = minetest.get_meta(pos)
		meta:set_string("dstack", stack:to_string())
		meta:set_string("dnode", minetest.serialize(node))

		return nodecore.scaling_particles(pos, {
				time = 0.1,
				amount = 40,
				minexptime = 0.02
			})
	end
end

nodecore.register_limited_abm({
		label = "node displacement decay",
		interval = 1,
		chance = 1,
		limited_max = 100,
		nodenames = {nodename},
		ignore_stasis = true,
		action = function(pos)
			for _, p in pairs(minetest.get_connected_players()) do
				if nodecore.scaling_closenough(pos, p) then return end
			end
			local meta = minetest.get_meta(pos)
			local node = minetest.deserialize(meta:get_string("dnode"))
			if not (node and node.name) then
				return minetest.remove_node(pos)
			end
			local stack = meta:get_string("dstack") or ""
			minetest.set_node(pos, node)
			nodecore.stack_set(pos, stack)
		end
	})
