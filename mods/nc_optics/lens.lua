-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, string, vector
    = minetest, nodecore, string, vector
local string_gsub
    = string.gsub
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function lens_check(pos, node, recv, getnode)
	local face = nodecore.facedirs[node.param2]

	if recv(face.k) and node.name ~= modname .. ":lens_on" then
		if node.name == modname .. ":lens_glow" then
			return modname .. ":lens_glow"
		else
			return modname .. ":lens_glow_start"
		end
	end

	local fore = vector.add(pos, face.f)
	local nnode = getnode(fore)
	local def = minetest.registered_items[nnode.name] or {}
	if (def.light_source and def.light_source > 3)
	or (def.groups and def.groups.activates_lens) then
		return modname .. ":lens_on"
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
	backface_culling = true,
	groups = {
		silica = 1,
		silica_lens = 1,
		optic_check = 1,
		optic_lens = 1,
		cracky = 3,
		scaling_time = 125,
		optic_gluable = 1
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
		light_source = 1,
		groups = {optic_source = 1, optic_lens_emit = 1},
		optic_source = function(_, node)
			return {nodecore.facedirs[node.param2].k}
		end
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
reg("_glow_start", {
		description = "Shining Lens",
		light_source = 1,
		groups = {activates_lens = 1, lens_glow_start = 1},
		tiles = {
			txr .. "^" .. modname .. "_shine_side.png",
			txr .. "^" .. modname .. "_shine_end.png^" .. pinp,
			txr .. "^" .. modname .. "_shine_end.png^" .. pact,
		}
	})

nodecore.register_dnt({
		name = modname .. ":lens_warmup",
		nodenames = {"group:lens_glow_start"},
		time = 2,
		autostart = true,
		action = function(pos, node)
			node.name = string_gsub(node.name, "_start", "")
			return nodecore.set_node(pos, node)
		end
	})

minetest.register_abm({
		label = "lens fire start",
		interval = 2,
		chance = 2,
		nodenames = {"group:optic_lens_emit"},
		action_delay = true,
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

local function getdir(v)
	if (v.y * v.y) > (v.x * v.x + v.z * v.z) then
		if v.y >= 0 then return {x = 0, y = 1, z = 0} end
		return {x = 0, y = -1, z = 0}
	elseif (v.x * v.x) > (v.z * v.z) then
		if v.x >= 0 then return {x = 1, y = 0, z = 0} end
		return {x = -1, y = 0, z = 0}
	end
	if v.z >= 0 then return {x = 0, y = 0, z = 1} end
	return {x = 0, y = 0, z = -1}
end

nodecore.register_aism({
		label = "lens light",
		interval = 1,
		chance = 1,
		itemnames = {"group:optic_lens"},
		action = function(stack, data)
			local glow = data.player and
			nodecore.optic_scan_recv(
				vector.round(data.pos),
				getdir(data.player:get_look_dir()),
				nil,
				minetest.get_node)
			local nn = modname .. ":lens" .. (glow and "_glow" or "")
			if stack:get_name() == nn then return end
			stack:set_name(nn)
			return stack
		end
	})
