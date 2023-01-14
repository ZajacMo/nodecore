-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs
    = ItemStack, math, minetest, nodecore, pairs
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
	local times = gcaps[k].times
	for n = 1, 100 do
		if not times[n] then
			local t = 10 * v * math_pow(2, n)
			if t > 60 then t = 60 end
			times[n] = t
		end
	end
end

minetest.register_item(":", {
		["type"] = "none",
		inventory_image = "[combine:1x1",
		tool_capabilities = toolcaps,
		node_placement_prediction = ""
	})

minetest.register_node(modname .. ":hand", {
		description = "",
		drawtype = "mesh",
		mesh = modname .. ".obj",
		tiles = {"nc_player_model_base.png"},
		use_texture_alpha = "clip",
		wield_scale = {x = 2, y = 2, z = 2},
		virtual_item = true,
		stack_max = 1,
		node_placement_prediction = "",
		paramtype = "light",
		on_punch = minetest.remove_node,
		on_use = function() return ItemStack("") end,
		on_drop = function() return ItemStack("") end,
		on_place = function() return ItemStack("") end,
	})

nodecore.register_aism({
		label = "clean up misplaced player hands",
		interval = 1,
		chance = 1,
		itemnames = {modname .. ":hand"},
		action = function(_, data)
			if data.player and data.list == "hand" then return end
			return ItemStack("")
		end
	})
nodecore.register_lbm({
		name = modname .. ":cleanup",
		run_at_every_load = true,
		nodenames = {modname .. ":hand"},
		action = function(pos) return minetest.remove_node(pos) end
	})

nodecore.register_on_joinplayer("join set hand", function(player)
		local inv = player:get_inventory()
		inv:set_size("hand", 1)
		inv:set_stack("hand", 1, modname .. ":hand")
	end)
