-- LUALOCALS < ---------------------------------------------------------
local core, ipairs, nc, pairs, string, table, type, vector
    = core, ipairs, nc, pairs, string, table, type, vector
local string_format, table_concat
    = string.format, table.concat
-- LUALOCALS > ---------------------------------------------------------

local rotation_center_ratio = 1/5
nc.rotation_center_ratio = rotation_center_ratio

local vec_to_dir = nc.vector_to_dir

local vector_add = vector.add
local vector_multiply = vector.multiply
local vector_subtract = vector.subtract
local vector_cross = vector.cross
local vector_equals = vector.equals

local boxscales = {}
do
	local function warn(k, sel, msg)
		return core.log("warning", string_format(
				"nc_api_rotatable node %q issue %q with box: %s", k, msg,
				sel ~= nil and core.serialize(sel) or "nil"))
	end
	local function selboxcheck(k, sel)
		if not sel then
			warn(k, sel, "undefined")
			return 1
		end
		local t = sel["type"]
		if t == "regular" then return 1 end
		if t ~= "fixed" then
			warn(k, sel, "not normal or fixed")
			return 1
		end
		local f = sel.fixed
		if (not f) or type(f) ~= "table" then
			warn(k, sel, "invalid fixed def")
			return 1
		end
		if #f ~= 1 then
			warn(k, sel, "#cuboids != 1")
			return 1
		end
		if type(f[1]) ~= "table" or #(f[1]) ~= 6 then
			warn(k, sel, "invalid cuboid")
			return 1
		end
		local n = f[1][1]
		if type(n) ~= "number" then
			warn(k, sel, "invalid dimension")
			return 1
		end
		if f[1][2] ~= n or f[1][3] ~= n
		or f[1][4] ~= -n or f[1][5] ~= -n or f[1][6] ~= -n then
			warn(k, sel, "non-symmetrical")
			return 1
		end
		return -n * 2
	end
	core.after(0, function()
			for k, v in pairs(core.registered_nodes) do
				if v.groups then
					local a = v.groups.nc_api_rotate_above
					local u = v.groups.nc_api_rotate_under
					if a and a > 0 or u and u > 0 then
						boxscales[k] = selboxcheck(k,
							v.selection_box)
					end
				end
			end
		end)
end

local function rotkey(v, param2)
	return table_concat({
			param2,
			-- negative zeros >:-(
			v.x == 0 and 0 or v.x,
			v.y == 0 and 0 or v.y,
			v.z == 0 and 0 or v.z
		}, ":")
end

local rotation_lut = {}
do
	local vz = vector.zero()
	local function rotcheck(a, b, c)
		local x = vector_cross(a, b)
		return vector.equals(x, vz) and vector_equals(a, b) or vector_equals(x, c)
	end
	for _, dir in ipairs(nc.dirs()) do
		for fromp2 = 0, 23 do
			local fromfd = nc.facedirs[fromp2]
			local key = rotkey(dir, fromp2)
			for top2 = 0, 23 do
				if fromp2 ~= top2 then
					local tofd = nc.facedirs[top2]
					if rotcheck(fromfd.t, tofd.t, dir)
					and rotcheck(fromfd.f, tofd.f, dir)
					then
						rotation_lut[key] = top2
						break
					end
				end
				if rotation_lut[key] ~= nil then break end
			end
		end
	end
end

local function getcheck(pname, pos, group, player, pointed)
	if core.is_protected(pos, pname) then return end
	local node = core.get_node_or_nil(pos)
	if not node then return end
	local def = core.registered_nodes[node.name]
	if not def then return end
	local grps = def.groups
	if not (grps and (grps[group] or 0) > 0) then return end
	if def.nc_rotate_allow and not def.nc_rotate_allow(pos, node, player, pointed)
	then return end
	return pos, node, def
end

function nc.rotation_compute(player, pointed_thing)
	if not (pointed_thing and pointed_thing.above and pointed_thing.under
		and pointed_thing.intersection_point
		and pointed_thing.intersection_normal) then return end

	if not (player and nc.interact(player)) then return end
	local pname = player:get_player_name()
	local pos, node, def = getcheck(pname, pointed_thing.above,
		"nc_api_rotate_above", player, pointed_thing)
	if not pos then
		pos, node, def = getcheck(pname, pointed_thing.under,
			"nc_api_rotate_under", player, pointed_thing)
		if not pos then return end
	end
	local boxscale = boxscales[node.name] or 1

	local function setparam2(data)
		local computed = nc.param2_canonical({
				name = node.name,
				param2 = rotation_lut[rotkey(data.vector, node.param2)]
			})
		if computed.param2 ~= node.param2 then
			data.param2 = computed.param2
		end
	end

	local facectr = vector_add(
		vector.multiply(pointed_thing.under, (2 - boxscale) / 2),
		vector.multiply(pointed_thing.above, boxscale / 2)
	)
	local facerel = vector_subtract(pointed_thing.intersection_point, facectr)

	local cdata = {
		vector = pointed_thing.intersection_normal,
		facectr = facectr,
		facerel = facerel,
		boxscale = boxscale,
	}
	setparam2(cdata)

	local cratio = rotation_center_ratio * boxscale
	if facerel.x > -cratio and facerel.x < cratio
	and facerel.y > -cratio and facerel.y < cratio
	and facerel.z > -cratio and facerel.z < cratio
	then return pos, node, cdata, def end

	local rotdir = vec_to_dir(facerel)
	local rdata = {
		vector = vector_cross(pointed_thing.intersection_normal, rotdir),
		facectr = facectr,
		facerel = facerel,
		rotdir = rotdir,
		boxscale = boxscale,
	}
	setparam2(rdata)
	return pos, node, rdata, def
end

local function raycast(player)
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local look = player:get_look_dir()
	local wield = core.registered_items[player
	:get_wielded_item():get_name()]
	local range = wield and wield.range or 4
	local target = vector_add(pos, vector_multiply(look, range))
	for pt in core.raycast(pos, target, true, false) do
		if pt.type == "object" or pt.ref ~= player
		or pt.ref:get_attach() ~= player then
			return pt
		end
	end
end

function nc.rotation_apply(player, pointed_thing)
	if not (pointed_thing and pointed_thing.above
		and pointed_thing.under) then return end

	local pt = raycast(player)
	if not (pt and pt.above and vector_equals(pt.above, pointed_thing.above)
		and pt.under and vector_equals(pt.under, pointed_thing.under))
	then return end

	local pos, node, rotdata, def = nc.rotation_compute(player, pt)
	if not (rotdata and rotdata.param2) then return end

	if player:is_player() then
		nc.log("action", player:get_player_name() .. " rotates "
			.. node.name .. " at " .. core.pos_to_string(pos)
			.. " from param2 " .. node.param2 .. " to " .. rotdata.param2)
	end
	node.param2 = rotdata.param2
	core.swap_node(pos, node)
	nc.node_sound(pos, "place")
	if def.on_nc_rotate then def.on_nc_rotate(pos, node) end
end

function nc.rotation_on_rightclick(_, _, clicker, _, pointed)
	return nc.rotation_apply(clicker, pointed)
end
