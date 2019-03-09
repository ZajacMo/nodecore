-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_random
    = math.random
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

local txr = modname .. "_glass_frost.png"

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
		txr,
		txr,
		txr,
		txr,
		txr .. "^" .. modname .. "_lens_out.png",
		txr .. "^" .. modname .. "_lens_in.png",
	},
	groups = {
		optic_check = 1,
		cracky = 3
	},
	drop = modname .. ":lens",
	on_construct = nodecore.optic_check,
	on_destruct = nodecore.optic_check,
	on_spin = nodecore.optic_check,
	optic_check = lens_check,
	paramtype = "light",
	paramtype2 = "facedir",
	on_rightclick = nodecore.node_spin_filtered(function(a, b)
			return vector.equals(a.f, b.f)
		end)
}

local function reg(suff, def)
	minetest.register_node(modname .. ":lens" .. suff,
		nodecore.underride(def, basedef))
end
reg("", {})
reg("_on", {
		description = "Active Lens",
		light_source = 2
	})
reg("_glow", {
		description = "Shining Lens",
		light_source = 12,
		tiles = {
			txr,
			txr,
			txr,
			txr,
			txr .. "^" .. modname .. "_lens_in.png",
			txr .. "^" .. modname .. "_lens_out.png",
		},	
	})

nodecore.register_limited_abm({
		label = "Lens Fire Starting",
		interval = 2,
		chance = 2,
		nodenames = {modname .. ":lens_on"},
		action = function(pos, node)
			local face = nodecore.facedirs[node.param2]
			local out = vector.add(face.k, pos)
			local tn = minetest.get_node(out)
			local tdef = minetest.registered_items[tn.name] or {}
			local flam = tdef and tdef.groups and tdef.groups.flammable
			if flam and math_random(1, flam) == 1 then
				nodecore.ignite(out, tn)
			end
		end
	})
