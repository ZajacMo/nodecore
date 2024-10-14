-- LUALOCALS < ---------------------------------------------------------
local core
    = core
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local nodename = modname .. ":displaced"
core.register_node(nodename, {
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

core.register_abm({
		label = "displaced node restore",
		interval = 1,
		chance = 1,
		nodenames = {nodename},
		ignore_stasis = true,
		action = function(pos)
			local meta = core.get_meta(pos)
			local node = core.deserialize(meta:get_string("dnode"))
			if not (node and node.name) then
				return core.remove_node(pos)
			end
			local dmeta = core.deserialize(meta:get_string("dmeta"))
			core.set_node(pos, node)
			if dmeta then core.get_meta(pos):from_table(dmeta) end
		end
	})
