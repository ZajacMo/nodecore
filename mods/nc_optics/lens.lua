-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function lens_check(pos, node, check)
	local face = nodecore.facedirs[node.param2]

	if check(face.k) then
		nodecore.node_change(pos, node, modname .. ":lens_glow")
		return
	end

	local fore = vector.add(pos, face.f)
	local ll = minetest.get_node_light(fore)
	local on = ll >= 15 and face.f.y == 1
	if not on then
		local node = minetest.get_node(fore)
		local def = minetest.registered_items[node.name]
		on = def and def.light_source and def.light_source > 4
	end
	if on then
		nodecore.node_change(pos, node, modname .. ":lens_on")
		return {face.k}
	end
	nodecore.node_change(pos, node, modname .. ":lens")
end

local basedef = {
	description = "Lens",
	drawtype = "nodebox",
	node_box = nodecore.fixedbox(
		{-0.5, -0.5, -3/8, 0.25, -0.25, 1/8},
		{-0.25, 0.25, -3/8, 0.5, 0.5, 1/8},
		{-0.5, -0.25, -3/8, -0.25, 0.5, 1/8},
		{0.25, -0.5, -3/8, 0.5, 0.25, 1/8},
		{-0.25, -0.25, -1/8, 0.25, 0.25, 0.25}
	),
	tiles = {
		"nc_optics_glass.png",
		"nc_optics_glass.png",
		"nc_optics_glass.png",
		"nc_optics_glass.png",
		"nc_optics_glass.png^nc_optics_lens_out.png",
		"nc_optics_glass.png^nc_optics_lens_in.png",
	},
	groups = {
		optic_check = 1,
		cracky = 1
	},
	drop = modname .. ":lens",
	on_construct = nodecore.optic_check,
	on_destruct = nodecore.optic_check,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rightclick = nodecore.node_spin,
	optic_check = lens_check
}

local function reg(suff, def)
	minetest.register_node(modname .. ":lens" .. suff,
		nodecore.underride(def, basedef))
end
reg("", {})
reg("_on", {description = "Lens (On)", light_source = 2})
reg("_glow", {description = "Lens (Glowing)", light_source = 12})
