-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, vector
    = ItemStack, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local presstoolcaps = {}
minetest.after(0, function()
		for name, def in pairs(minetest.registered_items) do
			if def.tool_capabilities then
				presstoolcaps[name] = {dig = true, groups = def.tool_capabilities.groupcaps}
			elseif def.tool_head_capabilities then
				presstoolcaps[name] = {groups = def.tool_head_capabilities.groupcaps}
			end
		end
	end)

local function checktarget(data, stack)
	local target = vector.subtract(vector.multiply(
			data.pointed.under, 2), data.pointed.above)
	data.presstarget = target
	local node = minetest.get_node(target)
	local def = minetest.registered_items[node.name] or {walkable = true}

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
			local tstack = nodecore.stack_get(target)
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
		return nodecore.craft_search(target, node, pumdata)
	end
	if minetest.get_item_group(stackname, "nc_doors_pummel_first") then
		data.presscommit = pummelcheck()
		if data.presscommit then return data.presscommit end
	end

	-- Try to dig item
	if caps.dig and def and def.groups
	and nodecore.tool_digs(stack, def.groups) then
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

local hashpos = minetest.hash_node_position
local toolfxqueue
local function toolfx(toolpos, actpos)
	nodecore.node_sound(toolpos, "dig")
	if not toolfxqueue then
		toolfxqueue = {}
		minetest.after(0, function()
				for _, ent in pairs(minetest.luaentities) do
					local target = ent.is_stack and ent.poskey
					and toolfxqueue[ent.poskey]
					if target then
						local obj = ent.object
						local pos = ent.pos
						obj:set_pos(target)
						minetest.after(0.1, function()
								obj:move_to(pos)
							end)
					end
				end
				toolfxqueue = nil
			end)
	end
	toolfxqueue[hashpos(toolpos)] = actpos
end

local olddig = minetest.node_dig
function minetest.node_dig(pos, node, digger, ...)
	if not nodecore.machine_digging then
		return olddig(pos, node, digger, ...)
	end
	local oldprot = minetest.is_protected
	function minetest.is_protected(pos2, ...)
		if vector.equals(pos, pos2) then return end
		return oldprot(pos2, ...)
	end
	local function helper(...)
		minetest.is_protected = oldprot
		return ...
	end
	return helper(olddig(pos, node, digger, ...))
end

local function doitemeject(pos, data)
	if data.pressdig then
		toolfx(pos, data.presstarget)
		nodecore.machine_digging = data.pressdig
		minetest.dig_node(data.pressdig.pos)
		nodecore.witness({pos, data.pointed.above, data.presstarget}, "door dig")
		return
	end
	if data.presscommit then
		toolfx(pos, data.presstarget)
		data.presscommit()
		nodecore.witness({pos, data.pointed.above, data.presstarget}, "door pummel")
		return
	end

	local stack = nodecore.stack_get(pos)
	if (not stack) or stack:is_empty() then return end
	local one = ItemStack(stack:to_string())
	one:set_count(1)

	if data.intostorebox then
		nodecore.witness({pos, data.pointed.above, data.intostorebox}, "door store")
		one = nodecore.stack_add(data.intostorebox, one)
		nodecore.stack_sounds(data.intostorebox, "place")
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
		local doorlv = minetest.get_item_group(minetest.get_node(
				data.pointed.above).name, "door") or 0
		nodecore.item_eject(
			vector.add(pos, vector.multiply(vel, 0.25)),
			one, 0, 1, vector.multiply(vel, 2 + doorlv)
		)
	end
	nodecore.stack_sounds(pos, "dig")
	stack:take_item(1)
	if stack:is_empty() and nodecore.node_group("is_stack_only", pos) then
		return minetest.remove_node(pos)
	end
	nodecore.stack_set(pos, stack)
	return nodecore.witness({pos, data.pointed.above}, "door catapult")
end

nodecore.register_craft({
		action = "press",
		label = "eject item",
		priority = 2,
		nodes = {
			{match = {stacked = true, count = false}}
		},
		check = function(pos, data)
			local stack = nodecore.stack_get(pos)
			if (not stack) or stack:is_empty() then return end
			return checktarget(data, stack)
		end,
		after = doitemeject
	})

nodecore.register_craft({
		action = "press",
		label = "eject from storebox",
		priority = -1,
		nodes = {
			{match = {groups = {storebox = true}}}
		},
		check = function(pos, data)
			local stack = nodecore.stack_get(pos)
			if (not stack) or stack:is_empty() then return end

			if not checktarget(data, stack) then return end

			local pt = data.pointed
			local node = minetest.get_node(pt.under)
			local def = minetest.registered_items[node.name] or {}
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
