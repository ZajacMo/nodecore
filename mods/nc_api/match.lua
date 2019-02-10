-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local match_skip = {
	name = true,
	param2 = true,
	param = true,
	groups = true,
	stack = true,
	count = true,
	wear = true
}

function nodecore.match(thing, crit)
	if not thing then return end
	local stack = thing.stack
	if stack then
		thing.name = stack:get_name()
		thing.count = stack:get_count()
		thing.wear = stack:get_wear()
	end
	if not thing.name then
		thing = nodecore.underride(thing, minetest.get_node(thing))
	end

	if type(crit) == "string" then crit = {name = crit} end
	if crit.name and thing.name ~= crit.name then return end
	if crit.param2 and thing.param2 ~= crit.param2 then return end
	if crit.param and thing.param ~= crit.param then return end
	if crit.count and thing.count ~= crit.count then return end
	if crit.wear then
		if crit.wear < 1 then crit.wear = crit.wear * 65535 end
		if thing.wear > crit.wear then return end
	end

	local def = minetest.registered_items[thing.name]
	if crit.groups then
		if not def or not def.groups then return end
		for k, v in pairs(crit.groups) do
			if v == true then
				if not def.groups[k] then return end
			elseif v == false then
				if def.groups[k] then return end
			else				
				if def.groups[k] ~= v then return end
			end
		end
	end
	for k, v in pairs(crit) do
		if not match_skip[k] then
			if not def or def[k] ~= v then return end
		end
	end

	if crit.stack then
		local stack = minetest.get_meta(thing):get_inventory():get_stack("solo", 1)
		if (not stack) or stack:is_empty() then return end
		thing.stack = stack
		return nodecore.match(thing, crit.stack)
	end

	return thing
end
