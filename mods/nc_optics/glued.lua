-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, string, type
    = minetest, nodecore, pairs, string, type
local string_sub
    = string.sub
-- LUALOCALS > ---------------------------------------------------------

local suff = "_glued"
local overlay = "^nc_optics_glued.png"

nodecore.register_on_register_item(function(name, def)
		if not (def.groups and def.groups.optic_gluable
			and def.groups.optic_gluable > 0) then return end

		if string_sub(name, -#suff) == suff then return end

		local gluedname = name .. suff
		if minetest.registered_items[gluedname] then return end

		local oldcheck = def.optic_check
		local optic_check = oldcheck and function(pos, node, ...)
			local tn = {
				name = node.name,
				param = node.param,
				param2 = node.param2
			}
			if string_sub(tn.name, -#suff) == suff then
				tn.name = string_sub(tn.name, 1, -#suff - 1)
			end
			local nn = oldcheck(pos, tn, ...)
			return nn and nn .. suff
		end
		local tiles = {}
		for k, v in pairs(def.tiles or {}) do
			if type(v) == "string" then
				tiles[k] = v .. overlay
			else
				tiles[k] = nodecore.underride({name = v.name .. overlay}, v)
			end
		end
		local gluedef = nodecore.underride({
				description = "Glued " .. def.description,
				groups = {
					optic_gluable = 0
				},
				optic_check = optic_check,
				tiles = tiles
			}, def)
		gluedef.nc_optic_family = def.nc_optic_family .. "_glued"
		gluedef.nc_rotations = nil
		gluedef.on_rightclick = nil
		minetest.register_item(gluedname, gluedef)
	end)

nodecore.register_craft({
		label = "glue optic",
		action = "pummel",
		wield = {name = "nc_tree:eggcorn"},
		consumewield = 1,
		indexkeys = "group:optic_gluable",
		duration = 2,
		nodes = {{
				match = {groups = {optic_gluable = true}, stacked = false}
		}},
		after = function(pos, data)
			data.node.name = data.node.name .. suff
			return minetest.swap_node(pos, data.node)
		end
	})
