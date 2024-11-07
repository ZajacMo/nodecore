-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, pairs, vector
    = ItemStack, core, nc, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local presstoolcaps = {}
core.after(0, function()
		for name, def in pairs(core.registered_items) do
			local caps
			if def.tool_capabilities then
				caps = {dig = true, groups = def.tool_capabilities.groupcaps}
			elseif def.tool_head_capabilities then
				caps = {groups = def.tool_head_capabilities.groupcaps}
			end
			if core.get_item_group(name, "nc_doors_pummel_first") > 0 then
				caps.pummelfirst = true
			end
			presstoolcaps[name] = caps
		end
	end)

local function checktarget(data, stack)
	local target = vector.subtract(vector.multiply(
			data.pointed.under, 2), data.pointed.above)
	data.presstarget = target
	local node = core.get_node(target)
	local def = core.registered_items[node.name] or {walkable = true}

	-- Inject item into available storebox
	if def.groups and def.groups.visinv and (def.groups.is_stack_only
		or def.storebox_access and def.storebox_access({
				type = "node",
				above = target,
				under = vector.subtract(vector.multiply(
						target, 2), data.pointed.under)
			})) then
		-- Never insert from bottom, so we can always dig
		local dir = vector.subtract(data.pointed.under, data.pointed.above)
		if dir.y <= 0 then
			local one = ItemStack(stack:to_string())
			one:set_count(1)
			local tstack = nc.stack_get(target)
			if tstack:item_fits(one) then
				data.intostorebox = target
				return true
			end
		end
	end

	local stackname = stack:get_name()
	local caps = presstoolcaps[stackname]
	local function pummelcheck()
		if not caps then return end
		local pumdata = {
			action = "pummel",
			pos = target,
			pointed = {
				type = "node",
				above = data.pointed.under,
				under = target
			},
			node = node,
			nodedef = def,
			duration = 3600,
			presstoolpos = data.pointed.under,
			wield = stack,
			toolgroupcaps = caps.groups
		}

		-- if pummelfirst doesn't find anything, can't find
		-- anything on second pass
		pummelcheck = function() end

		return nc.craft_search(target, node, pumdata)
	end
	if caps and caps.pummelfirst then
		data.presscommit = pummelcheck()
		if data.presscommit then return data.presscommit end
	end

	-- Try to dig item
	if caps and caps.dig and def and def.groups
	and nc.tool_digs(stack, def.groups) then
		data.pressdig = {
			pos = target,
			tool = stack,
			toolpos = data.pointed.under
		}
		return true
	end

	-- Eject item as entity
	if not def.walkable then return true end

	data.presscommit = pummelcheck()
	return data.presscommit
end

local hashpos = core.hash_node_position
local toolfxqueue
local function toolfx(toolpos, actpos)
	nc.node_sound(toolpos, "dig")
	if not toolfxqueue then
		toolfxqueue = {}
		core.after(0, function()
				for _, ent in pairs(core.luaentities) do
					local target = ent.is_stack and ent.poskey
					and toolfxqueue[ent.poskey]
					if target and ent.homepos then
						local obj = ent.object
						obj:set_pos(vector.add(target,
								vector.subtract(ent.homepos,
									ent.pos)))
						core.after(0.1, function()
								obj:move_to(ent.homepos)
							end)
					end
				end
				toolfxqueue = nil
			end)
	end
	toolfxqueue[hashpos(toolpos)] = actpos
end

local function doitemeject(pos, data)
	if data.pressdig then
		toolfx(pos, data.presstarget)
		nc.machine_digging = data.pressdig
		nc.protection_bypass(core.dig_node, data.pressdig.pos)
		nc.machine_digging = nil
		nc.witness({pos, data.pointed.above, data.presstarget}, "door dig")
		return
	end
	if data.presscommit then
		toolfx(pos, data.presstarget)
		data.presscommit()
		nc.witness({pos, data.pointed.above, data.presstarget}, "door pummel")
		return
	end

	local stack = nc.stack_get(pos)
	if (not stack) or stack:is_empty() then return end
	local one = ItemStack(stack:to_string())
	one:set_count(1)

	if data.intostorebox then
		nc.witness({pos, data.pointed.above, data.intostorebox}, "door store")
		one = nc.stack_add(data.intostorebox, one)
		nc.stack_sounds(data.intostorebox, "place")
		if not one:is_empty() then return end
	else
		local ctr = {
			x = data.axis.x ~= 0 and data.axis.x or pos.x,
			y = data.axis.y ~= 0 and data.axis.y or pos.y,
			z = data.axis.z ~= 0 and data.axis.z or pos.z
		}
		local vel = vector.add(
			vector.subtract(pos, ctr),
			vector.subtract(data.pointed.under, data.pointed.above)
		)
		local doorlv = core.get_item_group(core.get_node(
				data.pointed.above).name, "door") or 0
		nc.item_eject(
			vector.add(pos, vector.multiply(vel, 0.25)),
			one, 0, 1, vector.multiply(vel, 2 + doorlv)
		)
	end
	nc.stack_sounds(pos, "dig")
	stack:take_item(1)
	if stack:is_empty() and nc.node_group("is_stack_only", pos) then
		return core.remove_node(pos)
	end
	nc.stack_set(pos, stack)
	return nc.witness({pos, data.pointed.above}, "door catapult")
end

nc.register_craft({
		action = "press",
		label = "eject item",
		priority = 2,
		nodes = {
			{match = {stacked = true, count = false}}
		},
		check = function(pos, data)
			local stack = nc.stack_get(pos)
			if (not stack) or stack:is_empty() then return end
			return checktarget(data, stack)
		end,
		after = doitemeject
	})

nc.register_craft({
		action = "press",
		label = "eject from storebox",
		priority = -1,
		nodes = {
			{match = {groups = {storebox = true}}}
		},
		check = function(pos, data)
			local stack = nc.stack_get(pos)
			if (not stack) or stack:is_empty() then return end

			if not checktarget(data, stack) then return end

			local pt = data.pointed
			local node = core.get_node(pt.under)
			local def = core.registered_items[node.name] or {}
			if not def.storebox_access then return end

			local access = {
				type = "node",
				above = vector.add(vector.multiply(
						vector.subtract(pt.above, pt.under),
						-1), pt.under),
				under = pt.under
			}
			return def.storebox_access(access)
		end,
		after = doitemeject
	})
