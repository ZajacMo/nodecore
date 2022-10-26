-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local bulks = nodecore["registered_" .. modname .. "_bulk_nodes"]

local basedef = minetest.registered_items[modname .. ":stack"]

local function register_full_stack(name, tiles)
	local stack_name = modname .. ":bulk_" .. name:gsub("^:", ""):gsub(":", "__")
	bulks[name] = stack_name
	if not tiles then
		minetest.register_node(stack_name, {})
		return
	end
	minetest.register_node(":" .. stack_name, nodecore.underride({
				drawtype = "mesh",
				mesh = modname .. "_stack.obj",
				tiles = tiles,
				paramtype2 = "facedir",
				groups = {
					visinv_hidden = 1,
				}
			}, basedef))
end

nodecore.register_on_register_item({
		retroactive = true,
		func = function(name, def)
			if def.visinv_bulk_optimize then
				def.visinv_bulk_optimize = nil
				register_full_stack(name, def.tiles)
			end
		end
	})

nodecore.register_lbm({
		name = modname .. ":bulk_convert",
		nodenames = {"group:is_stack_only"},
		action = function(pos, node)
			local nn = nodecore.stack_bulk_check(pos, node)
			if not nn then return end
			minetest.swap_node(pos, nn)
			return nodecore.visinv_update_ents(pos)
		end
	})
