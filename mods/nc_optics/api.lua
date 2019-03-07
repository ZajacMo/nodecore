-- LUALOCALS < ---------------------------------------------------------
local error, minetest, nodecore, pairs, pcall, table, vector
    = error, minetest, nodecore, pairs, pcall, table, vector
-- LUALOCALS > ---------------------------------------------------------

--[[

- in metadata, store which direction we're transmitting; always the
  same distance.
  
- in check cb, call node check code and pass it:
	pos, node, func(dir)
  func is a function that checks for power in, returns pos if
  hit, nil if not.
	- this callback may change the node.
	- should return a table containing dirs in which to transmit
	  power
	- caller will setup metadata.
	

- It's the receiver's responsibility to trace back to transmitters.

- Transmitting node will offer a func to check if it's transmitting
  in a particular direction.
  
- Transmitter can notify receivers of a change, but receivers need
  to do the checking.
  
- Each node will cache the result of its own receive check into
  metadata in order to answer the transmit inquiry.
  
--]]

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
		if node.name ~= "air" then return p, node end
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

local function optic_check_auto(pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def and def.optic_check then return optic_check(pos) end
end

local function optic_process(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def and def.optic_check then
		local func = function(dir)
			local hit, node = scan_recv(pos, dir)
			if hit == false then error("UNLOADED") end
			return hit, node
		end
		local ok, res = pcall(def.optic_check, pos, node, func, def)
		if ok then
			local data = {}
			for k, v in pairs(res or {}) do
				data[dirname(v)] = 1
			end
			minetest.get_meta(pos):set_string("nc_optics",
				minetest.serialize(data))
		elseif res ~= "UNLOADED" then
			error(res)
		end
		return
	end
	for _, dir in pairs(nodecore.dirs()) do
		local p, node = scan(pos, dir)
		if p then optic_check_auto(p, node) end
	end		
end

minetest.register_globalstep(function()
		-- snapshot batch, as processing may write to queue
		local batch = optic_queue
		optic_queue = {}

		for _, pos in pairs(batch) do
			optic_process(pos)
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
