-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local nodedata = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.buildable_to then
				nodedata[k] = true
			end
			if v.groups and v.groups.falling_node and v.groups.falling_node > 0 then
				nodedata[k] = false
			end
		end
	end)

-- Check if a node is "supported by a backstop" within a certain
-- distance in a certain direction, such that if the node were
-- pushed in that direction, there would be no room to "give".

local function backstop(pos, dir, depth)
	if depth <= 0 then return end
	pos = vector.add(pos, dir)
	local nodename = minetest.get_node(pos).name
	local data = nodedata[nodename]
	if data then return end
	if data == false then
		return backstop(pos, dir, depth - 1)
	end
	return true
end

nodecore.node_backstop = backstop
