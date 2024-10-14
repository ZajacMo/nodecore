-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, ipairs, math, nc, pairs, setmetatable, string,
      type, unpack, vector
    = ItemStack, core, ipairs, math, nc, pairs, setmetatable, string,
      type, unpack, vector
local math_random, string_format, string_gsub
    = math.random, string.format, string.gsub
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()
local dntname = modname .. ":cookcheck"

local stacks_only = nc.group_expand("group:is_stack_only", true)

local nevermatch = {}
local function nomatches(k)
	local stack = ItemStack(k)
	for _, rc in ipairs(nc.registered_recipes) do
		if rc.action == "cook" then
			if nc.match({stack = stack}, rc.root.match) then return end
		end
	end
	return true
end
core.after(0, function()
		for k in pairs(core.registered_items) do
			if nomatches(k) then nevermatch[k] = true end
		end
	end)

local function flameblock(sum) sum.flame = nil end
nc.register_dnt({
		name = dntname,
		time = 1,
		arealoaded = 1,
		nodenames = {"group:visinv"},
		action = function(pos, node)
			node.stack = nc.stack_get(pos)
			local data = nc.craft_cooking_data()
			if core.get_item_group(node.name, "is_stack_only") == 0 then
				data.touchgroupmodify = flameblock
			end
			nc.craft_check(pos, node, data)
			if not data.progressing then
				nc.craft_cooking_reset_meta(pos)
			else
				return nc.dnt_set(pos, dntname, 1 + math_random())
			end
		end
	})

core.register_abm({
		label = "item stack cook",
		nodenames = {"group:visinv"},
		interval = 2,
		chance = 1,
		action = function(pos)
			if nevermatch[nc.stack_get(pos):get_name()] then return end
			return nc.dnt_set(pos, dntname, 1 + math_random())
		end
	})

-- this function abstracts the actual placement, choosing between node or stack form
local item_place_node_or_stack = function(itemstack, placer, pointed_thing, param2)
	local def = itemstack:get_definition()
	if def.type == "node" and not def.place_as_item then
		return core.item_place_node(itemstack, placer, pointed_thing, param2)
	end
	if not itemstack:is_empty() then
		local above = core.get_pointed_thing_position(pointed_thing, true)
		if above and nc.buildable_to(above) then
			if def.type == "node" and def.node_placement_prediction ~= "" then
				nc.stack_node_sounds_except[core.hash_node_position(above)]
				= placer:get_player_name()
			end
			nc.place_stack(above, itemstack:take_item(), placer, pointed_thing)
		end
	end
	return itemstack
end
nc.item_place_node_or_stack = item_place_node_or_stack

-- placement on right click: place the item as a node or stack as appropriate,
-- unless the destination has an on_rightclick override and the player is not sneak-placing,
-- in which case the on_rightclick override is invoked instead
function core.item_place(itemstack, placer, pointed_thing, param2)
	if not nc.interact(placer) then return end
	if pointed_thing.type == "node" and placer and
	not placer:get_player_control().sneak then
		local n = core.get_node(pointed_thing.under)
		local nn = n.name
		local nd = core.registered_items[nn]
		if nd and nd.on_rightclick then
			return nd.on_rightclick(pointed_thing.under, n,
				placer, itemstack, pointed_thing) or itemstack, false
		end
	end
	return item_place_node_or_stack(itemstack, placer, pointed_thing, param2)
end

local olddrop = core.item_drop
function core.item_drop(item, player, ...)
	if not (player and player:is_player()) then
		return olddrop(item, player, ...)
	end
	local oldadd = core.add_item
	local function additem(pos, stack, ...)
		nc.log("action", string_format("%s throws item %q at %s",
				player:get_player_name(), nc.stack_shortdesc(stack),
				core.pos_to_string(pos, 0)))
		return oldadd(pos, stack, ...)
	end
	function core.add_item(pos, stack, ...)
		local start = player:get_pos()
		local eyeheight = player:get_properties().eye_height or 1.625
		start.y = start.y + eyeheight
		local target = vector.add(start, vector.multiply(player:get_look_dir(), 4))
		local pointed = core.raycast(start, target, false)()
		if (not pointed) or pointed.type ~= "node" then
			return additem(pos, stack, ...)
		end

		local dummyent = {}
		setmetatable(dummyent, {
				__index = function()
					return function() return {} end
				end
			})

		local function tryplace(p)
			if stacks_only[core.get_node(p).name] then
				stack = nc.stack_add(p, stack, player)
				if stack:is_empty() then return dummyent end
			end
			if nc.buildable_to(p) then
				nc.place_stack(p, stack, player)
				return dummyent
			end
		end

		return tryplace(pointed.under)
		or tryplace(pointed.above)
		or additem(pos, stack, ...)
	end
	local function helper(...)
		core.add_item = oldadd
		return ...
	end
	return helper(olddrop(item, player, ...))
end

local oldlog = core.log
function core.log(...)
	local args = {...}
	if args[1] == "action" then
		args[2] = args[2] and type(args[2]) == "string"
		and string_gsub(args[2], "(( digs " .. modname .. ":stack)( at (%(.-%))))",
			function(full, pre, post, pos)
				pos = pos and core.string_to_pos(pos)
				local stack = pos and nc.stack_get(pos)
				if stack then
					return string_format("%s %q%s", pre,
						nc.stack_shortdesc(stack), post)
				end
				return full
			end
		) or args[2]
	end
	return oldlog(unpack(args))
end
