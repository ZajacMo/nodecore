-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
= minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local node_is_skip = {
	name = true,
	param2 = true,
	param = true,
	groups = true,
	visinv = true,
	count = true,
	wear = true,
	metadata = true,
}
function nodecore.node_is(thing, match)
	if not thing.name then
		local p = { }
		for k, v in pairs(minetest.get_node(thing)) do
			p[k] = v
		end
		for k, v in pairs(thing) do
			p[k] = v
		end
		thing = p
	end
	while type(match) == "function" do
		match = match(thing)
		if not match then return end
		if match == true then return thing end
	end
	if type(match) == "string" then match = {name = match} end
	if match.name and thing.name ~= match.name then return end
	if match.param2 and thing.param2 ~= match.param2 then return end
	if match.param and thing.param ~= match.param then return end
	if match.count and thing.count ~= match.count then return end
	if match.wear and thing.wear ~= match.wear then return end
	if match.metadata and thing.metadata ~= match.metadata then return end
	local def = minetest.registered_items[thing.name]
	if match.groups then
		if not def.groups then return end
		for k, v in pairs(match.groups) do
			if v == true then
				if not def.groups[k] then return end
			elseif v == false then
				if def.groups[k] then return end
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
	if match.visinv then
		local stack = minetest.get_meta(thing)
		:get_inventory():get_stack("solo", 1)
		if not stack or stack:is_empty() then return end
		local p = { }
		p.name = stack:get_name()
		p.count = stack:get_count()
		p.wear = stack:get_wear()
		p.metadata = stack:get_metadata()
		return nodecore.node_is(p, match.visinv)
	end
	return thing
end
function nodecore.buildable_to(node_or_pos)
	return nodecore.node_is(node_or_pos, {buildable_to = true})
end
