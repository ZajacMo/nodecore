-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
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

minetest.register_abm({
		label = "displaced node restore",
		interval = 1,
		chance = 1,
		nodenames = {nodename},
		ignore_stasis = true,
		action = function(pos)
			local meta = minetest.get_meta(pos)
			local node = minetest.deserialize(meta:get_string("dnode"))
			if not (node and node.name) then
				return minetest.remove_node(pos)
			end
			local dmeta = minetest.deserialize(meta:get_string("dmeta"))
			minetest.set_node(pos, node)
			if dmeta then minetest.get_meta(pos):from_table(dmeta) end
		end
	})
