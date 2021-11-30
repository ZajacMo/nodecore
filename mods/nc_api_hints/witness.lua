-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table, vector
    = math, minetest, nodecore, pairs, table, vector
local math_pi, table_remove
    = math.pi, table.remove
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local seethru = {}
minetest.after(0, function()
		for name, def in pairs(minetest.registered_nodes) do
			if (minetest.get_item_group(name, "witness_opaque") == 0)
			and (
				minetest.get_item_group(name, "witness_transparent") > 0
				or def.sunlight_propagates
				or (
					def.paramtype == "light"
					and def.alpha
					and def.alpha > 0
					and def.alpha < 255
				)

			) then
				seethru[name] = true
			end
		end
	end)

local metakey = modname .. "_witness"
local cache = {}
local function witnessdata(player)
	local pname = player:get_player_name()
	local meta = player:get_meta()
	local data = cache[pname]
	if not data then
		data = meta:get_string(metakey) or ""
		data = data and data ~= "" and minetest.deserialize(data)
		or {queue = {}, lookup = {}}
		cache[pname] = data
	end
	return data, function() return meta:set_string(metakey, minetest.serialize(data)) end
end

local function canwitnessnow(player, pos)
	local ppos = player:get_pos()
	ppos.y = ppos.y + player:get_properties().eye_height

	local look = player:get_look_dir()
	local targ = vector.normalize(vector.subtract(pos, ppos))
	if vector.angle(look, targ) > math_pi / 8 then return end

	local rp = vector.round(pos)
	for pt in minetest.raycast(pos, ppos, false, true) do
		if not pt.under then return end
		if vector.equals(pt.under, rp) then return true end
		local node = minetest.get_node(pt.under)
		if not seethru[node.name] then return end
	end
	return true
end

local function witnesslater(player, pos, disc)
	local data, save = witnessdata(player)
	local newdata = {
		node = minetest.get_node(pos).name,
		stack = nodecore.stack_get(pos):get_name(),
		disc = disc
	}
	local posstr = minetest.pos_to_string(pos)
	local olddata = data.lookup[posstr]
	if olddata and (olddata.node == newdata.node) and (olddata.stack
		== newdata.stack) then
		for k in pairs(disc) do olddata.disc[k] = true end
	else
		data.queue[#data.queue + 1] = pos
		while #data.queue > 100 do table_remove(data.queue, 1) end
		data.lookup[posstr] = newdata
	end
	save()
end

function nodecore.witness(pos, disc, maxdist)
	maxdist = maxdist or 16
	for _, player in pairs(minetest.get_connected_players()) do
		local ppos = player:get_pos()
		if vector.distance(ppos, pos) <= maxdist then
			if canwitnessnow(player, pos) then
				nodecore.player_discover(player, disc, "witness:")
			else
				witnesslater(player, pos, disc, "witness:")
			end
		end
	end
end

local function delayed_witness(pos, node, player)
	local data, save = witnessdata(player)
	local posstr = minetest.pos_to_string(pos)
	local found = data.lookup[posstr]
	if not found then return end
	data.lookup[posstr] = nil
	save()
	node = node or minetest.get_node(pos)
	if (found.node ~= node.name) or (nodecore.stack_get(pos):get_name()
		~= found.stack) then return end
	return nodecore.player_discover(player, found.disc)
end
minetest.register_on_punchnode(delayed_witness)
nodecore.register_on_node_stare(function(player, pt)
		delayed_witness(pt.under, minetest.get_node(pt.under), player)
	end)
