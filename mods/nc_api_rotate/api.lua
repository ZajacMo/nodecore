-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, table, vector
    = ipairs, minetest, nodecore, table, vector
local table_concat
    = table.concat
-- LUALOCALS > ---------------------------------------------------------

local vec_to_dir = nodecore.vector_to_dir

local vector_add = vector.add
local vector_multiply = vector.multiply
local vector_subtract = vector.subtract
local vector_cross = vector.cross
local vector_equals = vector.equals

local function rotkey(v, param2)
	return table_concat({
			param2,
			-- negative zeros >:-(
			v.x == 0 and 0 or v.x,
			v.y == 0 and 0 or v.y,
			v.z == 0 and 0 or v.z
		}, ":")
end

do
	local vz = vector.zero()
	local function rotcheck(a, b, c)
		local x = vector_cross(a, b)
		return vector.equals(x, vz) and vector_equals(a, b) or vector_equals(x, c)
	end
	function nodecore.rotation_filter(equiv_func)
		local lut = {}
		for _, dir in ipairs(nodecore.dirs()) do
			for fromp2 = 0, 23 do
				local fromfd = nodecore.facedirs[fromp2]
				local key = rotkey(dir, fromp2)
				for top2 = 0, 23 do
					if fromp2 ~= top2 then
						local tofd = nodecore.facedirs[top2]
						if rotcheck(fromfd.t, tofd.t, dir)
						and rotcheck(fromfd.f, tofd.f, dir)
						then
							for chkp2 = 0, top2 do
								if chkp2 == top2 or equiv_func(
									nodecore.facedirs[chkp2],
									tofd
								) then
									lut[key] = top2
									break
								end
							end
							break
						end
					end
					if lut[key] then break end
				end
			end
		end
		return lut
	end
end

local function getcheck(pname, pos, group)
	if minetest.is_protected(pos, pname) then return end
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	local def = minetest.registered_nodes[node.name]
	if not def then return end
	local grps = def.groups
	if not (grps and (grps[group] or 0) > 0) then return end
	local rots = def.nc_rotations
	if not rots then return end
	return pos, node, rots
end

function nodecore.rotation_compute(player, pointed_thing)
	if not (pointed_thing and pointed_thing.above and pointed_thing.under
		and pointed_thing.intersection_point
		and pointed_thing.intersection_normal) then return end

	local pname = player:get_player_name()
	local pos, node, lut = getcheck(pname, pointed_thing.above, "nc_api_rotate_above")
	if not pos then
		pos, node, lut = getcheck(pname, pointed_thing.under, "nc_api_rotate_under")
		if not pos then return end
	end

	local facectr = vector_multiply(vector_add(pointed_thing.above, pointed_thing.under), 0.5)
	local facerel = vector_subtract(pointed_thing.intersection_point, facectr)

	local cdata = {
		vector = pointed_thing.intersection_normal,
		facectr = facectr,
		facerel = facerel,
	}
	cdata.param2 = lut[rotkey(cdata.vector, node.param2)]

	if cdata.param2
	and facerel.x > -1/4 and facerel.x < 1/4
	and facerel.y > -1/4 and facerel.y < 1/4
	and facerel.z > -1/4 and facerel.z < 1/4
	then return pos, node, cdata end

	local rotdir = vec_to_dir(facerel)
	local rdata = {
		vector = vector_cross(pointed_thing.intersection_normal, rotdir),
		facectr = facectr,
		facerel = facerel,
		rotdir = rotdir,
	}
	rdata.param2 = lut[rotkey(rdata.vector, node.param2)]
	if rdata.param2 then return pos, node, rdata end

	if cdata.param2 then return pos, node, cdata end
end

local function raycast(player)
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local look = player:get_look_dir()
	local wield = minetest.registered_items[player
	:get_wielded_item():get_name()]
	local range = wield and wield.range or 4
	local target = vector_add(pos, vector_multiply(look, range))
	for pt in minetest.raycast(pos, target, true, false) do
		if pt.type == "object" or pt.ref ~= player
		or pt.ref:get_attach() ~= player then
			return pt
		end
	end
end

function nodecore.rotation_apply(player, pointed_thing)
	if not (pointed_thing and pointed_thing.above
		and pointed_thing.under) then return end

	local pt = raycast(player)
	if not (pt and pt.above and vector_equals(pt.above, pointed_thing.above)
		and pt.under and vector_equals(pt.under, pointed_thing.under))
	then return end

	local pos, node, rotdata = nodecore.rotation_compute(player, pt)
	if not rotdata then return end

	node.param2 = rotdata.param2
	nodecore.set_loud(pos, node)
end

function nodecore.rotation_on_rightclick(_, _, clicker, _, pointed)
	return nodecore.rotation_apply(clicker, pointed)
end
