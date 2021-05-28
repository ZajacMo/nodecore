-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs
    = ipairs, math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local queue
local function process()
	local expire = minetest.get_us_time() * 200000
	local batch = {}
	for _, v in pairs(queue) do batch[#batch + 1] = v end
	queue = nil
	for i = #batch, 2, -1 do
		local j = math_random(1, i)
		if j ~= i then
			local x = batch[i]
			batch[i] = batch[j]
			batch[j] = x
		end
	end
	for i = 1, #batch do
		if minetest.get_us_time() > expire then
			nodecore.log("warning", "skipping " .. (#batch - i + 1)
				.. " inverted ABM actions due to time budget")
			return
		end
		local v = batch[i]
		local nnode = minetest.get_node(v.pos)
		if nnode.name == v.node.name then
			v.action(v.pos, nnode)
		end
	end
end

local hash = minetest.hash_node_position

local oldreg = minetest.register_abm
function minetest.register_abm(def, ...)
	if not def.neighbors_invert then return oldreg(def, ...) end

	local nnames = def.nodenames
	def.nodenames = def.neighbors
	def.neighbors = nnames

	local oldact = def.action

	function def.action(pos)
		if not queue then
			queue = {}
			minetest.after(0, process)
		end
		for _, npos in ipairs(nodecore.find_nodes_around(pos, nnames, 1)) do
			queue[hash(npos)] = {
				pos = npos,
				node = minetest.get_node(npos),
				action = oldact
			}
		end
	end

	return oldreg(def, ...)
end
