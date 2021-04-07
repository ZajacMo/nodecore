-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, type, vector
    = ItemStack, minetest, nodecore, pairs, type, vector
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes with a "drop_in_place" spec transform on node drop by dropping
into place of existing node instead of digger inventory.
--]]

local function yielditem(pos, digger, stack)
	if digger and digger:is_player() then
		stack = digger:get_inventory():add_item("main", stack)
	end
	if stack:is_empty() then return end
	minetest.chat_send_all(stack:to_string())
	return nodecore.item_eject(pos, stack)
end

local olddig = minetest.node_dig
function minetest.node_dig(pos, node, digger, ...)
	local def = node and node.name and minetest.registered_nodes[node.name]
	if def and def.drop_in_place then
		local oldrm = minetest.remove_node
		local function helper(...)
			minetest.remove_node = oldrm
			nodecore.silktouch_digging = nil
			return ...
		end
		function minetest.remove_node(p2, ...)
			if not vector.equals(pos, p2) then return oldrm(p2, ...) end
			minetest.remove_node = oldrm

			local tool = digger and digger:is_player()
			and digger:get_wielded_item()
			or nodecore.machine_digging
			and vector.equals(nodecore.machine_digging.pos, pos)
			and nodecore.machine_digging.tool

			nodecore.machine_digging = nil

			if def.silktouch and digger and nodecore.tool_digs(tool,
				def.silktouch) then
				nodecore.silktouch_digging = true
				yielditem(pos, digger, ItemStack(node.name))
				return oldrm(p2, ...)
			end

			if def.drop_non_silktouch then
				return yielditem(pos, digger,
					ItemStack(def.drop_non_silktouch))
			end

			return minetest.set_node(pos, {
					name = def.drop_in_place.name,
					param = def.drop_in_place.param or node.param,
					param2 = def.drop_in_place.param2 or node.param2
				})
		end
		return helper(olddig(pos, node, digger, ...))
	end
	return olddig(pos, node, digger, ...)
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" or not def.drop_in_place then return end

		if type(def.drop_in_place) ~= "table" then
			def.drop_in_place = {name = def.drop_in_place}
		end

		def.drop_non_silktouch = def.drop_non_silktouch
		or def.drop ~= "" and def.drop
		def.drop = ""

		def.node_dig_prediction = def.node_dig_prediction or def.drop_in_place.name

		if def.silktouch == nil then
			def.silktouch = {}
			for k, v in pairs(def.groups or {}) do
				def.silktouch[k] = v + 5
			end
		end
	end)
