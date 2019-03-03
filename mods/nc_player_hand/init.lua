-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

minetest.register_item(":", {
		type = "none",
		wield_image = "nc_player_hand.png",
		wield_scale = {x=1, y=1, z=2.5},
		tool_capabilities = nodecore.toolcaps({
				uses = 0,
				crumbly = 1,
				snappy = 1,
				thumpy = 1
			})
	})
