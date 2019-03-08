-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
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

local txr = modname .. "_glass_frost.png"

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
		txr,
		txr,
		txr .. "^" .. modname .. "_prism_in.png",
		txr .. "^" .. modname .. "_lens_out.png",
		txr .. "^" .. modname .. "_lens_out.png",
		txr .. "^(" .. modname .. "_prism_in.png^[transformFX)",
	},
	groups = {
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
		end)
}

local function reg(suff, def)
	minetest.register_node(modname .. ":prism" .. suff,
		nodecore.underride(def, basedef))
end
reg("", {})
reg("_on", {
		description = "Active Prism",
		light_source = 2
	})
