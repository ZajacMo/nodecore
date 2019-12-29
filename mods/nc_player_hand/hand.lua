-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_pow
    = math.pow
-- LUALOCALS > ---------------------------------------------------------

local toolcaps = nodecore.toolcaps({
		uses = 0,
		crumbly = 1,
		snappy = 1,
		thumpy = 1
	})
local gcaps = toolcaps.groupcaps
for k, v in pairs(nodecore.tool_basetimes) do
	gcaps[k] = gcaps[k] or {uses = 0, times = {}}
	for n = 1, 100 do
		gcaps[k].times[n] = gcaps[k].times[n] or (10 * v * math_pow(2, n))
	end
end

minetest.register_item(":", {
		["type"] = "none",
		wield_image = "nc_player_hand.png",
		wield_scale = {x = 4, y = 8, z = 3},
		tool_capabilities = toolcaps
	})
