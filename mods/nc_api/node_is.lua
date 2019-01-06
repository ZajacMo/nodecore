-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local node_is_skip = {name = true, param2 = true, param = true, groups = true}
function nodecore.node_is(node_or_pos, match)
	if not node_or_pos.name then
		local p = { }
		for k, v in pairs(minetest.get_node(node_or_pos)) do
			p[k] = v
		end
		for k, v in pairs(node_or_pos) do
			p[k] = v
		end
		node_or_pos = p
	end
	while type(match) == "function" do
		match = match(node_or_pos)
		if not match then return end
		if match == true then return node_or_pos end
	end
	if type(match) == "string" then match = {name = match} end
	if match.name and node_or_pos.name ~= match.name then return end
	if match.param2 and node_or_pos.param2 ~= match.param2 then return end
	if match.param and node_or_pos.param ~= match.param then return end
	local def = minetest.registered_nodes[node_or_pos.name]
	if match.groups then
		if not def.groups then return end
		for k, v in match.groups do
			if v == true then
				if not def.groups[k] then return end
			else
				if def.groups[k] ~= v then return end
			end
		end
	end
	for k, v in pairs(match) do
		if not node_is_skip[k] then
			if def[k] ~= v then return end
		end
	end
	return node_or_pos
end
function nodecore.buildable_to(node_or_pos)
	return nodecore.node_is(node_or_pos, {buildable_to = true})
end
