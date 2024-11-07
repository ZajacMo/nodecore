-- LUALOCALS < ---------------------------------------------------------
local core, nc, pairs, type
    = core, nc, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local match_skip = {
	name = true,
	param2 = true,
	param = true,
	groups = true,
	stack = true,
	count = true,
	excess = true,
	wear = true,
	stacked = true,
	any = true,
	empty = true,
	stackany = true
}

function nc.match(thing, crit)
	if not thing then return end

	if type(crit) == "string" then crit = {name = crit} end

	if crit.any then
		for _, v in pairs(crit.any) do
			local found = nc.match(thing, v)
			if found then return found end
		end
		return
	end

	-- Allow matches on stacks inside any node, not only
	-- bare stack nodes.
	if crit.stackany then
		local subcrit = nc.underride({}, crit)
		subcrit.stackany = nil
		if nc.match(thing, subcrit) then return thing end
	end

	thing.count = thing.count or 1

	thing = nc.underride({}, thing)
	if thing.stack then
		thing.name = thing.stack:get_name()
		thing.count = thing.stack:get_count()
		thing.wear = thing.stack:get_wear()
		thing.stacked = true
	end
	if not thing.name then
		thing = nc.underride(thing, core.get_node(thing))
	end
	local def = core.registered_items[thing.name]
	if crit.stackany or (not thing.stacked) and def and def.groups
	and def.groups.is_stack_only then
		local stack = thing.x and thing.y and thing.z and nc.stack_get(thing)
		if stack and not stack:is_empty() then
			thing.name = stack:get_name()
			def = core.registered_items[thing.name]
			thing.count = stack:get_count()
			thing.wear = stack:get_wear()
		end
		thing.stacked = true
	end
	if crit.stacked and not thing.stacked then return end
	if crit.stacked == false and thing.stacked then return end

	thing.name = thing.name and core.registered_aliases[thing.name] or thing.name

	if crit.name and thing.name ~= crit.name then return end
	if crit.param2 and thing.param2 ~= crit.param2 then return end
	if crit.param and thing.param ~= crit.param then return end
	if crit.count and thing.count < crit.count then return end
	if crit.count and (not crit.excess) and thing.count > crit.count then return end
	if crit.count == nil and thing.count ~= 1 then return end
	if crit.wear then
		if crit.wear < 1 then crit.wear = crit.wear * 65535 end
		if thing.wear and (thing.wear > crit.wear) then return end
	end

	if crit.groups then
		if (not def) or (not def.groups) then return end
		for k, v in pairs(crit.groups) do
			if v == true then
				if (not def.groups[k]) or def.groups[k] == 0 then return end
			elseif v == false then
				if def.groups[k] and def.groups[k] ~= 0 then return end
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

	-- Never match on a thing that also has a stack inside it, e.g. crafts on
	-- shelfs/forms that are full.
	if crit.empty and not (thing.stacked or nc.stack_get(thing)
		:is_empty()) then return end

	return thing
end
