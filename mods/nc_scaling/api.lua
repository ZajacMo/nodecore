-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, vector
    = ItemStack, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.scaling_light_level = 3

function nodecore.scaling_particles(pos, def)
	def = nodecore.underride(def or {}, {
			texture = "[combine:1x1^[noalpha",
			collisiondetection = false,
			amount = 5,
			time = 1,
			minpos = {x = pos.x - 0.4, y = pos.y - 0.4, z = pos.z - 0.4},
			maxpos = {x = pos.x + 0.4, y = pos.y + 0.4, z = pos.z + 0.4},
			minvel = {x = -0.02, y = -0.02, z = -0.02},
			maxvel = {x = 0.02, y = 0.02, z = 0.02},
			minexptime = 1,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 0.25
		})
	for _, player in pairs(minetest.get_connected_players()) do
		local pp = player:get_pos()
		pp.y = pp.y + 1
		if vector.distance(pos, pp) then
			local t = {}
			for k, v in pairs(def) do t[k] = v end
			t.playername = player:get_player_name()
			minetest.add_particlespawner(t)
		end
	end
end

local function issolid(pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if not def or not def.walkable then return end
	if def.groups and (not def.groups.falling_node) then
		return {pos = pos, node = node}
	end
	if nodecore.tool_digs(ItemStack(""), def.groups) then return end
	return {pos = pos, node = node}
end

local function tryreplace(pos, newname, rootpos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if not (def and def.buildable_to and def.air_equivalent) then return end

	newname = modname .. ":" .. newname

	local lv = def.groups and def.groups[modname]
	if lv then
		local ndef = minetest.registered_nodes[newname]
		if ndef.groups[modname] < lv then return true end
	end

	minetest.set_node(pos, {name = newname})
	minetest.get_meta(pos):set_string("data", minetest.serialize({
				pos = rootpos,
				node = minetest.get_node(rootpos).name
			}))
	nodecore.scaling_particles(pos)

	return true
end

function nodecore.scaling_apply(pointed)
	if pointed.type ~= "node" or (not pointed.above) or (not pointed.under) then return end
	local pos = pointed.above
	if pointed.under.y > pointed.above.y and issolid(pointed.under) then
		if tryreplace(pos, "ceil", pointed.under) then
			if tryreplace({x = pos.x, y = pos.y - 1, z = pos.z}, "hang", pos) then
				tryreplace({x = pos.x + 1, y = pos.y - 1, z = pos.z}, "hang", pos)
				tryreplace({x = pos.x - 1, y = pos.y - 1, z = pos.z}, "hang", pos)
				tryreplace({x = pos.x, y = pos.y - 1, z = pos.z + 1}, "hang", pos)
				tryreplace({x = pos.x, y = pos.y - 1, z = pos.z - 1}, "hang", pos)
			end
			return true
		end
	elseif pointed.under.y == pointed.above.y and issolid(pointed.under) then
		local ok = tryreplace(pos, "wall", pointed.under)
		if ok then tryreplace({x = pos.x, y = pos.y - 1, z = pos.z}, "hang", pos) end
		return ok
	elseif pointed.under.y < pointed.above.y and issolid(pointed.under) then
		if (nodecore.get_node_light(pointed.above) or 1) < nodecore.scaling_light_level then
			return tryreplace(pos, "floor", pointed.under)
		end
	end
end
