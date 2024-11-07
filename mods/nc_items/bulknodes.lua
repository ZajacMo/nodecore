-- LUALOCALS < ---------------------------------------------------------
local core, error, nc, pairs, type
    = core, error, nc, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local bulks = nc["registered_" .. modname .. "_bulk_nodes"]

local basedef = core.registered_items[modname .. ":stack"]

local function register_full_stack(name, def)
	local stack_name = modname .. ":bulk_" .. name:gsub(":", "__")
	bulks[name] = stack_name
	if not def.tiles then
		return error("visinv_bulk_optimize invalid on nodes without tiles")
	end
	local tiles = {}
	for k, v in pairs(def.tiles) do
		tiles[k] = {
			name = type(v) == "string" and v or v.name,
			backface_culling = true
		}
	end
	core.register_node(":" .. stack_name, nc.underride({
				drawtype = "mesh",
				mesh = modname .. "_stack.obj",
				tiles = tiles,
				use_texture_alpha = def.use_texture_alpha,
				paramtype2 = "facedir",
				groups = {
					visinv_hidden = 1,
				},
				mapcolor = {a = 0},
			}, basedef))
end

nc.register_on_register_item({
		retroactive = true,
		func = function(name, def)
			if def.visinv_bulk_optimize then
				def.visinv_bulk_optimize = nil
				register_full_stack(name, def)
			end
		end
	})

nc.register_lbm({
		name = modname .. ":bulk_convert",
		nodenames = {"group:is_stack_only"},
		action = function(pos, node)
			local nn = nc.stack_bulk_check(pos, node)
			if not nn then return end
			core.swap_node(pos, nn)
			return nc.visinv_update_ents(pos)
		end
	})
