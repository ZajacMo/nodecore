-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore
    = ItemStack, minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local cheatdesc = "Cheat Torch"
local cheattrans = nodecore.translate(cheatdesc)

minetest.register_chatcommand("torchlite", {
		description = "Create long-lasting " .. cheattrans,
		privs = {["give"] = true},
		func = function(pname)
			local player = minetest.get_player_by_name(pname)
			if not player then return end
			local stack = ItemStack(modname .. ":torch_lit")
			local meta = stack:get_meta()
			meta:set_string("description", cheatdesc)
			meta:set_float("expire", 1e300)
			player:get_inventory():add_item("main", stack)
		end
	})
