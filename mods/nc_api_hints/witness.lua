-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, table, type, vector
    = minetest, nodecore, pairs, table, type, vector
local table_remove
    = table.remove
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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

function nodecore.witness(pos, label, maxdist)
	maxdist = maxdist or 16
	label = type(label) == "table" and label or {label}
	for _, player in pairs(minetest.get_connected_players()) do
		local ppos = player:get_pos()
		if vector.distance(ppos, pos) <= maxdist then
			local data, save = witnessdata(player)
			local newdata = {
				node = minetest.get_node(pos).name,
				stack = nodecore.stack_get(pos):get_name(),
				label = label
			}
			local posstr = minetest.pos_to_string(pos)
			local olddata = data.lookup[posstr]
			if olddata and (olddata.node == newdata.node) and (olddata.stack
				== newdata.stack) then
				for i = 1, #label do
					olddata.label[#olddata.label + 1] = label[i]
				end
			else
				data.queue[#data.queue + 1] = pos
				while #data.queue > 100 do table_remove(data.queue, 1) end
				data.lookup[posstr] = newdata
			end
			save()
		end
	end
end

minetest.register_on_punchnode(function(pos, node, puncher)
		local data, save = witnessdata(puncher)
		local posstr = minetest.pos_to_string(pos)
		local found = data.lookup[posstr]
		if not found then return end
		data.lookup[posstr] = nil
		save()
		node = node or minetest.get_node(pos)
		if (found.node ~= node.name) or (nodecore.stack_get(pos):get_name()
			~= found.stack) then return end
		local disc = found.label
		for i = 1, #found.label do disc["witness:" .. found.label[i]] = true end
		return nodecore.player_discover(puncher, disc)
	end)
