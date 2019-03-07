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

	if type(crit) == "string" then crit = {name = crit} end

	thing.count = thing.count or 1

	thing = nodecore.underride({}, thing)
	if thing.stack then
		thing.name = thing.stack:get_name()
		thing.count = thing.stack:get_count()
		thing.wear = thing.stack:get_wear()	
		thing.stacked = true
	end
	if not thing.name then
		thing = nodecore.underride(thing, minetest.get_node(thing))
	end
	local def = minetest.registered_items[thing.name]
	if (not thing.stacked) and def and def.groups and def.groups.is_stack_only then
		local stack = nodecore.stack_get(thing)
		if stack and not stack:is_empty() then
			thing.name = stack:get_name()
			def = minetest.registered_items[thing.name]
			thing.count = stack:get_count()
			thing.wear = stack:get_wear()
		end
		thing.stacked = true
	end

	if crit.name and thing.name ~= crit.name then return end
	if crit.param2 and thing.param2 ~= crit.param2 then return end
	if crit.param and thing.param ~= crit.param then return end
	if crit.count and thing.count ~= crit.count then return end
	if crit.count == nil and thing.count ~= 1 then return end
	if crit.wear then
		if crit.wear < 1 then crit.wear = crit.wear * 65535 end
		if thing.wear > crit.wear then return end
	end

	if crit.groups then
		if (not def) or (not def.groups) then return end
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

	return thing
end
