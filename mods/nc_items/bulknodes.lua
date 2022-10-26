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
				groups = {
					visinv_hidden = 1,
				},
				on_stack_update = function(pos, _, stack)
					if stack:get_count() < stack:get_stack_max() then
						return minetest.swap_node(pos, {name = modname .. ":stack"})
					end
				end
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
