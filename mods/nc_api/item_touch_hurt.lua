-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_on_register_item(function(_, def)
		local dmg = def.groups and def.groups.damage_touch
		if not (dmg and dmg > 0) then return end

		def.on_punch = def.on_punch or function(pos, node, puncher, ...)
			if puncher and puncher:is_player() then
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
