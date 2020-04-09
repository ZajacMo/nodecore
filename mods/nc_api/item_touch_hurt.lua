-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local function toolcandig(wield, node)
	if (not wield) or wield:is_empty() then return end
	local def = node and node.name and minetest.registered_items[node.name]
	if not (def and def.groups) then return end
	local toolspeed = nodecore.toolspeed(wield, def.groups)
	if not toolspeed then return end
	local handspeed = nodecore.toolspeed(ItemStack(""), def.groups)
	return handspeed and (toolspeed < handspeed)
end

nodecore.register_on_register_item(function(_, def)
		local dmg = def.groups and def.groups.damage_touch
		if not (dmg and dmg > 0) then return end

		def.on_punch = def.on_punch or function(pos, node, puncher, ...)
			if puncher and puncher:is_player()
			and (not toolcandig(puncher:get_wielded_item(), node)) then
				nodecore.addphealth(puncher, -dmg, {
						nc_type = "node_touch_hurt",
						node = node
					})
			end
			return minetest.node_punch(pos, node, puncher, ...)
		end

		def.on_scaling = def.on_scaling or function(_, _, player, node)
			if player and player:is_player() then
				nodecore.addphealth(player, -dmg, {
						nc_type = "node_touch_hurt",
						node = node
					})
			end
			return true
		end
	end)
