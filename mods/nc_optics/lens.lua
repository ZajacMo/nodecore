-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function lens_check(pos, node, check)
	local face = nodecore.facedirs[node.param2]

	if check(face.k) then
		return modname .. ":lens_glow"
	end

	local fore = vector.add(pos, face.f)
	local nnode = minetest.get_node(fore)
	local def = minetest.registered_items[nnode.name] or {}
	if def.light_source and def.light_source > 4 then
		return modname .. ":lens_on", {face.k}
	end

	return modname .. ":lens"
end

local txr = modname .. "_glass_frost.png"
local pact = modname .. "_port_active.png"
local pout = modname .. "_port_output.png"
local pinp = modname .. "_port_input.png"

local basedef = {
	description = "Lens",
	drawtype = "mesh",
	mesh = "nc_optics_lens.obj",
	selection_box = nodecore.fixedbox(
		{-7/16, -7/16, -3/8, 7/16, 7/16, 3/8}
	),
	tiles = {
		txr,
		txr .. "^" .. pout,
		txr .. "^" .. pinp
	},
	groups = {
		silica = 1,
		silica_lens = 1,
		optic_check = 1,
		cracky = 3,
		scaling_time = 125
	},
	silktouch = false,
	drop = modname .. ":lens",
	on_construct = nodecore.optic_check,
	on_destruct = nodecore.optic_check,
	on_spin = nodecore.optic_check,
	optic_check = lens_check,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rightclick = nodecore.node_spin_filtered(function(a, b)
			return vector.equals(a.f, b.f)
		end),
	sounds = nodecore.sounds("nc_optics_glassy")
}

local function reg(suff, def)
	minetest.register_node(modname .. ":lens" .. suff,
		nodecore.underride(def, basedef))
end
reg("", {})
reg("_on", {
		description = "Active Lens",
		tiles = {
			txr .. "^(" .. pact .. "^[opacity:96)",
			txr .. "^" .. pact .. "^" .. pout,
			txr .. "^" .. pinp .. "^" .. pout
		},
		light_source = 1
	})
reg("_glow", {
		description = "Shining Lens",
		light_source = 12,
		tiles = {
			txr .. "^" .. modname .. "_shine_side.png",
			txr .. "^" .. modname .. "_shine_end.png^" .. pinp,
			txr .. "^" .. modname .. "_shine_end.png^" .. pact,
		},
	})

nodecore.register_limited_abm({
		label = "lens fire start",
		interval = 2,
		chance = 2,
		nodenames = {modname .. ":lens_on"},
		action = function(pos, node)
			local face = nodecore.facedirs[node.param2]
			local out = vector.add(face.k, pos)
			local tn = minetest.get_node(out)
			local tdef = minetest.registered_items[tn.name] or {}
			local flam = tdef and tdef.groups and tdef.groups.flammable
			if flam then
				return nodecore.fire_check_ignite(out, tn)
			end
			if tdef.groups and tdef.groups.is_stack_only then
				local stack = nodecore.stack_get(out)
				return nodecore.fire_check_ignite(out, {
						name = stack:get_name(),
						count = stack:get_count()
					})
			end
		end
	})
