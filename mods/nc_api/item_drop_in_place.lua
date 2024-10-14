-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, pairs, type, vector
    = ItemStack, core, nc, pairs, type, vector
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
	return nc.item_eject(pos, stack)
end

local olddig = core.node_dig
function core.node_dig(pos, node, digger, ...)
	local def = node and node.name and core.registered_nodes[node.name]
	if def and def.drop_in_place then
		local oldrm = core.remove_node
		local function helper(...)
			core.remove_node = oldrm
			nc.silktouch_digging = nil
			return ...
		end
		function core.remove_node(p2, ...)
			if not vector.equals(pos, p2) then return oldrm(p2, ...) end
			core.remove_node = oldrm

			local tool = digger and digger:is_player()
			and digger:get_wielded_item()
			or nc.machine_digging
			and vector.equals(nc.machine_digging.auxpos
				or nc.machine_digging.pos, pos)
			and nc.machine_digging.tool

			if def.silktouch and digger and nc.tool_digs(tool,
				def.silktouch) then
				nc.silktouch_digging = true
				yielditem(pos, digger, ItemStack(def.silktouch_as or node.name))
				return oldrm(p2, ...)
			end

			if def.drop_non_silktouch then
				yielditem(pos, digger, ItemStack(def.drop_non_silktouch))
			end

			return nc.set_node(pos, {
					name = def.drop_in_place.name,
					param = def.drop_in_place.param or node.param,
					param2 = def.drop_in_place.param2 or node.param2
				})
		end
		return helper(olddig(pos, node, digger, ...))
	end
	return olddig(pos, node, digger, ...)
end

nc.register_on_register_item(function(_, def)
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
