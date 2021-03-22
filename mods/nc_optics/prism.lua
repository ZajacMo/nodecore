-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, vector
    = math, minetest, nodecore, vector
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function altblock(pos)
	return (math_floor((pos.x + 0.5) / 16)
		+ math_floor((pos.y + 0.5) / 16)
		+ math_floor((pos.z + 0.5) / 16))
	% 2 == 1
end

local function prism_check(pos, node, recv)
	local face = nodecore.facedirs[node.param2]

	if recv(face.t) or recv(face.b) then
		return modname .. ":prism_gated"
	end
	if recv(face.f) or recv(face.r) then
		return modname .. ":prism_on" .. (altblock(pos) and "_alt" or "")
	end
	return modname .. ":prism"
end

local txr = modname .. "_glass_frost.png"
local pact = modname .. "_port_active.png"
local pout = modname .. "_port_output.png"
local pinp = modname .. "_port_wide.png"
local pina = modname .. "_port_wide_act.png"
local shin = modname .. "_shine_end.png"
local dark = modname .. "_port_input.png"
local mask1 = "[mask:" .. modname .. "_blockmask_1.png"
local mask2 = "[mask:" .. modname .. "_blockmask_2.png"

local basedef = {
	description = "Prism",
	drawtype = "mesh",
	mesh = "nc_optics_prism.obj",
	selection_box = nodecore.fixedbox(
		{-7/16, -7/16, -7/16, 7/16, 7/16, 7/16}
	),
	tiles = {
		txr,
		txr .. "^" .. pout,
		txr .. "^" .. pinp
	},
	backface_culling = true,
	groups = {
		silica = 1,
		optic_check = 1,
		cracky = 3,
		silica_prism = 1,
		scaling_time = 125
	},
	silktouch = false,
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
			txr .. "^(" .. pact .. "^" .. mask1 .. "^[opacity:96)",
			txr .. "^(" .. pact .. "^" .. mask1 .. ")^" .. pout,
			txr .. "^" .. pinp .. "^" .. pina
		},
		light_source = 1,
		optic_source = function(_, node)
			local fd = nodecore.facedirs[node.param2]
			return {fd.k, fd.l}
		end
	})
reg("_on_alt", {
		description = "Active Prism",
		tiles = {
			txr .. "^(" .. pact .. "^" .. mask2 .. "^[opacity:96)",
			txr .. "^(" .. pact .. "^" .. mask2 .. ")^" .. pout,
			txr .. "^" .. pinp .. "^" .. pina
		},
		light_source = 1,
		optic_source = function(_, node)
			local fd = nodecore.facedirs[node.param2]
			return {fd.k, fd.l}
		end
	})
reg("_gated", {
		description = "Gated Prism",
		tiles = {
			txr .. "^" .. shin .. "^" .. pout,
			txr .. "^" .. shin .. "^" .. dark,
			txr .. "^" .. shin .. "^" .. dark
		},
		light_source = 1
	})
