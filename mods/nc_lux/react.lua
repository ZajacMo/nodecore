-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

minetest.register_abm({
		label = "lux reaction",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_cobble"},
		action = function(pos, node)
			local qty = nodecore.lux_react_qty(pos)
			local name = node.name:gsub("cobble%d", "cobble" .. qty)
			if name == node.name then return end
			minetest.set_node(pos, {name = name})
		end
	})

nodecore.register_aism({
		label = "lux stack reaction",
		interval = 1,
		chance = 2,
		itemnames = {"group:lux_cobble"},
		action = function(stack, data)
			local name = stack:get_name()
			if minetest.get_item_group(name, "lux_cobble") <= 0 then return end
			local qty = nodecore.lux_react_qty(data.pos)
			name = name:gsub("cobble%d", "cobble" .. qty)
			if name == stack:get_name() then return end
			stack:set_name(name)
			return stack
		end
	})
