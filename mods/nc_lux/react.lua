-- LUALOCALS < ---------------------------------------------------------
local core, nc
    = core, nc
-- LUALOCALS > ---------------------------------------------------------

core.register_abm({
		label = "lux reaction",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_cobble"},
		arealoaded = 1,
		action = function(pos, node)
			local qty = nc.lux_react_qty(pos)
			local name = node.name:gsub("cobble%d", "cobble" .. qty)
			if name == node.name then return end
			core.set_node(pos, {name = name})
		end
	})

nc.register_aism({
		label = "lux stack reaction",
		interval = 1,
		chance = 2,
		arealoaded = 1,
		itemnames = {"group:lux_cobble"},
		action = function(stack, data)
			local name = stack:get_name()
			if core.get_item_group(name, "lux_cobble") <= 0 then return end
			local qty = nc.lux_react_qty(data.pos)
			name = name:gsub("cobble%d", "cobble" .. qty)
			if name == stack:get_name() then return end
			stack:set_name(name)
			return stack
		end
	})
