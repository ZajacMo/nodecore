-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_pow
    = math.pow
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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
		inventory_image = "[combine:1x1",
		tool_capabilities = toolcaps,
		node_placement_prediction = ""
	})

local scale = 2
minetest.register_node(modname .. ":hand", {
		drawtype = "mesh",
		mesh = modname .. ".obj",
		tiles = {"nc_player_model_base.png"},
		wield_scale = {x = scale, y = scale, z = scale},
		virtual_item = true,
		stack_max = 1,
		node_placement_prediction = "",
		on_punch = minetest.remove_node
	})

minetest.register_on_joinplayer(function(player)
		local inv = player:get_inventory()
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, modname .. ":hand")
	end)
