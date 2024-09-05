-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

--[[--
Definition:
{
	ignore = {type_name = true, type_name_2 = true},
	-- Don't notify if triggered by these reasons.

	getnode = true,
	-- Make the 2nd "node" paramter required instead of optional.

	func = function(pos, node)
		-- Callback function.
	}
	--]]--

	local allreasons = {
		stack_set = true,
		set_node = true,
		add_node = true,
		remove_node = true,
		swap_node = true,
		dig_node = true,
		place_node = true,
		add_node_level = true,
		liquid_transformed = true,
	}

	local registered = {}
	for k in pairs(allreasons) do registered[k] = {} end

	local neednode = {}

	function nodecore.register_on_nodeupdate(def)
		if type(def) == "function" then
			nodecore.log("warning", "deprecated register_on_nodeupdate(function),"
				.. " use register_on_nodeupdate(table) instead")
			def = {
				func = def,
				getnode = true,
			}
		end
		for k in pairs(allreasons) do
			if not (def.ignore and def.ignore[k]) then
				if def.getnode then neednode[k] = true end
				local t = registered[k]
				t[#t + 1] = def.func
			end
		end
	end

	local hash = minetest.hash_node_position

	local mask = {}

	local function notify_node_update(reason, pos, node, ...)
		local phash = hash(pos)
		if mask[phash] then return ... end
		mask[phash] = true
		if neednode[reason] then node = node or minetest.get_node(pos) end
		local nups = registered[reason]
		for i = 1, #nups do
			(nups[i])(pos, node)
		end
		mask[phash] = nil
		return ...
	end
	nodecore.notify_node_update = notify_node_update

	for fn, param in pairs({
			set_node = true,
			add_node = true,
			remove_node = false,
			swap_node = true,
			dig_node = false,
			place_node = true,
			add_node_level = false
		}) do
		local func = minetest[fn]
		minetest[fn] = function(pos, pn, ...)
			return notify_node_update(fn, pos, param and pn, func(pos, pn, ...))
		end
	end

	if minetest.register_on_liquid_transformed then
		minetest.register_on_liquid_transformed(function(list)
				for i = 1, #list do
					notify_node_update("liquid_transformed", list[i])
				end
			end)
	end
