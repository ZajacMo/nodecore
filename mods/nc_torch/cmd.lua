-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest
    = ItemStack, minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_chatcommand("torchlite", {
		description = "Create long-lasting torch",
		privs = {["give"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local stack = ItemStack(modname .. ":torch_lit")
			local meta = stack:get_meta()
			meta:set_string("description", "Cheat Torch")
			meta:set_float("expire", 1e300)
			player:get_inventory():add_item("main", stack)
		end
	})
