-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function prism_check(pos, node, check)
	local face = nodecore.facedirs[node.param2]

	local power = (check(face.f) or check(face.r))
	and (not check(face.t)) and (not check(face.b))

	if power then
		nodecore.node_change(pos, node, modname .. ":prism_on")
		return {face.k, face.l}
	end
	nodecore.node_change(pos, node, modname .. ":prism")
end

local basedef = {
	description = "Prism",
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(
		{-3/8, -3/8, -0.5, -0.25, 3/8, -3/8},
		{3/8, -3/8, 0.25, 0.5, 3/8, 3/8},
		{-3/8, -0.5, -0.5, 0.5, -3/8, 3/8},
		{-3/8, 3/8, -0.5, 0.5, 0.5, 3/8},
		{-3/8, -3/8, -3/8, 3/8, 3/8, 3/8},
		{-0.25, -0.25, 3/8, 0.25, 0.25, 0.5},
		{-0.5, -0.25, -0.25, -3/8, 0.25, 0.25}
	),
	tiles = {
		"nc_optics_glass.png",
		"nc_optics_glass.png",
		"nc_optics_glass.png^nc_optics_prism_in.png",
		"nc_optics_glass.png^nc_optics_lens_out.png",
		"nc_optics_glass.png^nc_optics_lens_out.png",
		"nc_optics_glass.png^(nc_optics_prism_in.png^[transformFX)",
	},
	groups = {
		optic_check = 1,
		cracky = 1
	},
	drop = modname .. ":prism",
	on_construct = nodecore.optic_check,
	on_destruct = nodecore.optic_check,
	on_spin = nodecore.optic_check,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rightclick = nodecore.node_spin,
	optic_check = prism_check
}

local function reg(suff, def)
	minetest.register_node(modname .. ":prism" .. suff,
		nodecore.underride(def, basedef))
end
reg("", {})
reg("_on", {description = "Prism (On)", light_source = 2})
