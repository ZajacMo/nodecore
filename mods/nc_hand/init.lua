-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

minetest.register_item(":", {
		type = "none",
		wield_image = "nc_hand.png",
		wield_scale = {x=1, y=1, z=2.5},
		tool_capabilities = nodecore.toolcaps({
				uses = 0,
				crumbly = 1,
				snappy = 1,
				thumpy = 1
			})
	})

local function cheat() return {times={[1]=0.25, [2]=0.25, [3]=0.25}, uses=0} end
minetest.register_tool("nc_hand:cheat", {
		inventory_image = "nc_hand.png^[invert:rgb",
		wield_image = "nc_hand.png^[invert:rgb",
		wield_scale = {x=1, y=1, z=2.5},
		tool_capabilities = nodecore.toolcaps({
				uses = 0,
				crumbly = 100,
				cracky = 100,
				snappy = 100,
				choppy = 100,
				thumpy = 100
			})
	})
