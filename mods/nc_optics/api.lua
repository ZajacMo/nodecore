-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, pcall, vector
    = error, minetest, nodecore, pairs, pcall, vector
-- LUALOCALS > ---------------------------------------------------------

local optic_queue = {}

local function dirname(pos)
	if pos.x > 0 then return "e" end
	if pos.x < 0 then return "w" end
	if pos.y > 0 then return "u" end
	if pos.y < 0 then return "d" end
	if pos.z > 0 then return "n" end
	if pos.z < 0 then return "s" end
	return ""
end

local function scan(pos, dir)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	for i = 1, 16 do
		p = vector.add(p, dir)
		local node = minetest.get_node(p)
		if node.name == "ignore" then return false, node end
		local def = minetest.registered_items[node.name] or {}
		if not def.sunlight_propagates then return p, node end
	end
end

local function scan_recv(pos, dir)
	local hit, node = scan(pos, dir)
	if not hit then return hit, node end
	local data = minetest.get_meta(hit):get_string("nc_optics")
	if data == "" then return end
	dir = dirname(vector.multiply(dir, -1))
	if not minetest.deserialize(data)[dir] then return end
	return hit, node
end

local function optic_check(pos)
	optic_queue[minetest.hash_node_position(pos)] = pos
end
nodecore.optic_check = optic_check

local function optic_trigger(start, dir)
	local pos, node = scan(start, dir)
	if not node then return end
	local def = minetest.registered_items[node.name] or {}
	if def and def.optic_check then return optic_check(pos) end
end

local function optic_process(trans, pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}

	if def and def.optic_check then
		local func = function(dir)
			local hit, node = scan_recv(pos, dir)
			if hit == false then error("IgNoReArEa") end
			return hit, node
		end
		local meta = minetest.get_meta(pos)
		local old = meta:get_string("nc_optics")
		local ok, nn, res = pcall(def.optic_check, pos, node, func, def)
		if ok then
			local data = {}
			for k, v in pairs(res or {}) do
				data[dirname(v)] = 1
			end

			old = old and minetest.deserialize(old) or {}
			for _, dir in pairs(nodecore.dirs()) do
				local dn = dirname(dir)
				if old[dn] ~= data[dn] then
					optic_trigger(pos, dir)
				end	
			end

			local key = minetest.hash_node_position(pos)
			trans.nodes[key] = {pos = pos, nn = nn}
			trans.meta[key] = {pos = pos, data = data}
		elseif nn:match("IgNoReArEa") then
			minetest.log("optic check for "
				.. minetest.pos_to_string(pos)
				.. " hit unloaded area")
		else
			error(res)
		end
	end

	for _, dir in pairs(nodecore.dirs()) do
		optic_trigger(pos, dir)
	end		
end

minetest.register_globalstep(function()
		-- snapshot batch, as processing may write to queue
		local batch = optic_queue
		optic_queue = {}

		local trans = {nodes = {}, meta = {}}
		for _, pos in pairs(batch) do
			optic_process(trans, pos)
		end

		for _, v in pairs(trans.nodes) do
			local node = minetest.get_node(v.pos)
			if node.name ~= v.nn then
				node.name = v.nn
				minetest.set_node(v.pos, node)
			end
		end
		for _, v in pairs(trans.meta) do
			minetest.get_meta(v.pos):set_string("nc_optics",
				minetest.serialize(v.data))
		end
	end)

nodecore.register_limited_abm({
		label = "Optic Check",
		interval = 1,
		chance = 1,
		limited_max = 100,
		limited_alert = 100,
		nodenames = {"group:optic_check"},
		action = nodecore.optic_check
	})
