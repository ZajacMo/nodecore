-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

--[[

- It's the receiver's responsibility to trace back to transmitters.

- Transmitting node will offer a func to check if it's transmitting
  in a particular direction.
  
- Transmitter can notify receivers of a change, but receivers need
  to do the checking.
  
- Each node will cache the result of its own receive check into
  metadata in order to answer the transmit inquiry.
  
--]]

local optic_queue = {}

local function scan(pos, dir)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	for i = 1, 16 do
		p = vector.add(p, dir)
		local node = minetest.get_node(p)
		if p.name == "ignore" then return end
		if p.name ~= "air" then return p, node end
	end
end

local hash = minetest.hash_node_position
local unhash = minetest.get_position_from_hash

function nodecore.optic_recv(pos)
	local meta = minetest.get_meta(pos)
	local data = meta:get_string("nc_optic")
	if (not data) or (data == "") then return {} end
	data = minetest.deserialize(data)
	for _, dh in pairs(data) do
		local hit = scan(pos, unhash(dh))
end

function nodecore.optic_emit(pos, dir, switch)
end

function nodecore.optic_check(pos)
	optic_queue[minetest.hash_node_position(pos)] = pos
end

nodecore.register_limited_abm({
		label = "Optic Check",
		interval = 1,
		chance = 1,
		limited_max = 100,
		limited_alert = 100,
		nodenames = {"group:optic_check"},
		action = nodecore.optic_check
	})

function nodecore.optic_emit(pos, dir)
	local hit, node = scan(pos, dir)
	-- XXX: LEFT OFF HERE
end

local function optic_process(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	if def and def.optic_check then return def.optic_check(pos, node, def) end
	for _, dir in pairs(nodecore.dirs()) do
		local p, node = scan(pos, dir)
		if node then
			local def = minetest.registered_items[node.name] or {}
			if def.optic_check then nodecore.optic_check(p) end
		end
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
