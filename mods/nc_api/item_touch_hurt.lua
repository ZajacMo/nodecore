-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc
    = ItemStack, core, nc
-- LUALOCALS > ---------------------------------------------------------

local function toolcandig(wield, node)
	if (not wield) or wield:is_empty() then return end
	local def = node and node.name and core.registered_items[node.name]
	if not (def and def.groups) then return end
	local toolspeed = nc.toolspeed(wield, def.groups)
	if not toolspeed then return end
	local handspeed = nc.toolspeed(ItemStack(""), def.groups)
	return handspeed and (toolspeed < handspeed)
end

nc.register_on_register_item(function(_, def)
		local dmg = def.pointable ~= false and def.groups
		and def.groups.damage_touch
		if not (dmg and dmg > 0) then return end

		def.on_punch = def.on_punch or function(pos, node, puncher, ...)
			if puncher and puncher:is_player()
			and (not toolcandig(puncher:get_wielded_item(), node)) then
				nc.addphealth(puncher, -dmg, {
						nc_type = "node_touch_hurt",
						node = node
					})
			end
			return core.node_punch(pos, node, puncher, ...)
		end

		def.on_scaling = def.on_scaling or function(_, _, player, node)
			if player and player:is_player() then
				nc.addphealth(player, -dmg, {
						nc_type = "node_touch_hurt",
						node = node
					})
			end
			return true
		end
	end)
