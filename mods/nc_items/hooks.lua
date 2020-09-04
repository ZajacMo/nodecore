-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, minetest, nodecore, pairs, setmetatable,
      string, type, unpack, vector
    = ItemStack, ipairs, minetest, nodecore, pairs, setmetatable,
      string, type, unpack, vector
local string_format, string_gsub
    = string.format, string.gsub
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local dntname = modname .. ":cookcheck"

local nevermatch = {}
local function nomatches(k)
	local stack = ItemStack(k)
	for _, rc in ipairs(nodecore.registered_recipes) do
		if rc.action == "cook" then
			if nodecore.match({stack = stack}, rc.root.match) then return end
		end
	end
	return true
end
minetest.after(0, function()
		for k in pairs(minetest.registered_items) do
			if nomatches(k) then nevermatch[k] = true end
		end
	end)

nodecore.register_dnt({
		name = dntname,
		time = 1,
		nodenames = {modname .. ":stack"},
		action = function(pos, node)
			local data = nodecore.craft_cooking_data()
			nodecore.craft_check(pos, node, data)
			if not data.progressing then
				return minetest.get_meta(pos):set_string(modname, "")
			else
				return nodecore.dnt_set(pos, dntname)
			end
		end
	})

nodecore.register_limited_abm({
		label = "item stack cook",
		nodenames = {modname .. ":stack"},
		interval = 1,
		chance = 1,
		action = function(pos)
			if nevermatch[nodecore.stack_get(pos):get_name()] then return end
			return nodecore.dnt_set(pos, dntname)
		end
	})

function minetest.item_place(itemstack, placer, pointed_thing, param2)
	if not nodecore.interact(placer) then return end
	if pointed_thing.type == "node" and placer and
	not placer:get_player_control().sneak then
		local n = minetest.get_node(pointed_thing.under)
		local nn = n.name
		local nd = minetest.registered_items[nn]
		if nd and nd.on_rightclick then
			return nd.on_rightclick(pointed_thing.under, n,
				placer, itemstack, pointed_thing) or itemstack, false
		end
	end
	local def = itemstack:get_definition()
	if def.type == "node" and not def.place_as_item then
		return minetest.item_place_node(itemstack, placer, pointed_thing, param2)
	end
	if not itemstack:is_empty() then
		local above = minetest.get_pointed_thing_position(pointed_thing, true)
		if above and nodecore.buildable_to(above) then
			if def.type == "node" and def.node_placement_prediction ~= "" then
				nodecore.stack_node_sounds_except[minetest.hash_node_position(above)]
				= placer:get_player_name()
			end
			nodecore.place_stack(above, itemstack:take_item(), placer, pointed_thing)
		end
	end
	return itemstack
end

local olddrop = minetest.item_drop
function minetest.item_drop(item, player, ...)
	local oldadd = minetest.add_item
	local function additem(pos, stack, ...)
		nodecore.log("action", string_format("%s throws item %q at %s",
				player:get_player_name(), nodecore.stack_shortdesc(stack),
				minetest.pos_to_string(pos, 0)))
		return oldadd(pos, stack, ...)
	end
	function minetest.add_item(pos, stack, ...)
		local start = player:get_pos()
		local eyeheight = player:get_properties().eye_height or 1.625
		start.y = start.y + eyeheight
		local target = vector.add(start, vector.multiply(player:get_look_dir(), 4))
		local pointed = minetest.raycast(start, target, false)()
		if (not pointed) or pointed.type ~= "node" then
			return additem(pos, stack, ...)
		end

		local dummyent = {}
		setmetatable(dummyent, {
				__index = function()
					return function() return {} end
				end
			})

		local name = stack:get_name()
		local function tryplace(p)
			if nodecore.match(p, {name = name, count = false}) then
				stack = nodecore.stack_add(p, stack, player)
				if stack:is_empty() then return dummyent end
			end
			if nodecore.buildable_to(p) then
				nodecore.place_stack(p, stack, player)
				return dummyent
			end
		end

		return tryplace(pointed.under)
		or tryplace(pointed.above)
		or additem(pos, stack, ...)
	end
	local function helper(...)
		minetest.add_item = oldadd
		return ...
	end
	return helper(olddrop(item, player, ...))
end

local oldlog = minetest.log
function minetest.log(...)
	local args = {...}
	if args[1] == "action" then
		args[2] = args[2] and type(args[2]) == "string"
		and string_gsub(args[2], "(( digs " .. modname .. ":stack)( at (%(.-%))))",
			function(full, pre, post, pos)
				pos = pos and minetest.string_to_pos(pos)
				local stack = pos and nodecore.stack_get(pos)
				if stack then
					return string_format("%s %q%s", pre,
						nodecore.stack_shortdesc(stack), post)
				end
				return full
			end
		) or args[2]
	end
	return oldlog(unpack(args))
end
