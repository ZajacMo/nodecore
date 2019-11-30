-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function prism_check(_, node, check)
	local face = nodecore.facedirs[node.param2]

	local power = (check(face.f) or check(face.r))
	and (not check(face.t)) and (not check(face.b))

	if power then
		return modname .. ":prism_on", {face.k, face.l}
	end
	return modname .. ":prism"
end

local txr = modname .. "_glass_frost.png"
local pact = modname .. "_port_active.png"
local pout = modname .. "_port_output.png"
local pinp = modname .. "_port_wide.png"
local pina = modname .. "_port_wide_act.png"

local basedef = {
	description = "Prism",
	drawtype = "mesh",
	mesh = "nc_optics_prism.obj",
	selection_box = nodecore.fixedbox(
		{-5/16, -0.5, -0.5, 0.5, 0.5, 5/16}
	),
	tiles = {
		txr,
		txr .. "^" .. pout,
		txr .. "^" .. pinp
	},
	groups = {
		silica = 1,
		optic_check = 1,
		cracky = 3
	},
	drop = modname .. ":prism",
	on_construct = nodecore.optic_check,
	on_destruct = nodecore.optic_check,
	on_spin = nodecore.optic_check,
	optic_check = prism_check,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rightclick = nodecore.node_spin_filtered(function(a, b)
			return vector.equals(a.f, b.r)
			and vector.equals(a.r, b.f)
		end),
	sounds = nodecore.sounds("nc_optics_glassy")
}

local function reg(suff, def)
	minetest.register_node(modname .. ":prism" .. suff,
		nodecore.underride(def, basedef))
end
reg("", {})
reg("_on", {
		description = "Active Prism",
		tiles = {
			txr,
			txr .. "^" .. pact .. "^" .. pout,
			txr .. "^" .. pinp .. "^" .. pina
		},
		light_source = 2
	})
