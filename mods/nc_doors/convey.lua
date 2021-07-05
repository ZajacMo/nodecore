-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, vector
    = ipairs, minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

local queue = {}

local is_falling = {groups = {falling_node = true}}

local function pushcore(pos, node, dir, ...)
	if not dir then return end
	local to = vector.add(pos, dir)
	if nodecore.buildable_to(to) then
		node.param = nil
		queue[#queue + 1] = {
			from = pos,
			to = to,
			node = node
		}
		return true
	end
	return pushcore(pos, node, ...)
end
function nodecore.door_push(pos, ...)
	local node = minetest.get_node(pos)
	if not nodecore.match(node, is_falling) then return end
	return pushcore(pos, node, ...)
end

minetest.register_globalstep(function()
		for _, v in ipairs(queue) do
			local node = minetest.get_node(v.from)
			if node.name == v.node.name and node.param2 == v.node.param2
			and nodecore.buildable_to(v.to) then
				local meta = minetest.get_meta(v.from):to_table()
				minetest.remove_node(v.from)
				nodecore.set_loud(v.to, v.node)
				minetest.get_meta(v.to):from_table(meta)
			end
		end
		queue = {}
	end)
