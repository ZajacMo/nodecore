-- LUALOCALS < ---------------------------------------------------------
local minetest, type
    = minetest, type
-- LUALOCALS > ---------------------------------------------------------

minetest.register_item(":", {
		type = "none",
		wield_image = "nc_hand.png",
		wield_scale = {x=1, y=1, z=2.5},
		tool_capabilities = {
			full_punch_interval = 0.9,
			max_drop_level = 0,
			groupcaps = {
				crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
				snappy  =  {times={[2]=2.00, [3]=0.40}, uses=0, maxlevel=1},
				thumpy  =  {times={[3]=3.00}, uses=0, maxlevel=1},
			}
		}
	})
