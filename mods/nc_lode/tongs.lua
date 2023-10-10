-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore
    = ItemStack, math, minetest, nodecore
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local tongs_holdable = nodecore.group_expand("group:lode_temper_hot", true)

nodecore.register_lode("tongs", {
		type = "tool",
		description = "## Lode Tongs",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_tongs.png",
		stack_max = 1,
		light_source = 1,
		tool_wears_to = modname .. ":prill_# 5",
		bytemper = function(temper, def)
			-- glowing tongs can't hold anything
			if temper.name == "hot" then return end

			-- annealed lasts ~5min, tempered lasts 3x as long
			local wrate = 65536 / 300 / (temper.name == "tempered" and 3 or 1)

			def.on_item_hotpotato = function(player, myslot, mystack, itemslot, itemstack, dtime)
				-- only works on glowing lode things
				if not tongs_holdable[itemstack:get_name()] then return end

				-- item must be adjacent to tongs in inventory
				if myslot > itemslot + 1 or myslot < itemslot - 1 then return end

				local dwear = wrate * (dtime or 3)
				dwear = math_floor(dwear) + (math_random() < (dwear - math_floor(dwear))
					and 1 or 0)
				local oldname = mystack:get_name()
				mystack:add_wear(dwear)
				if mystack:get_count() < 1 then
					nodecore.toolbreakeffects(player, minetest.registered_items[oldname])
					mystack = ItemStack(modname .. ":prill_" .. temper.name .. " 5")
				end
				player:get_inventory():set_stack("main", myslot, mystack)

				return true
			end
		end
	})

-- nodecore.register_craft({
-- label = "anvil making lode tongs",
-- action = "pummel",
-- toolgroups = {thumpy = 3},
-- indexkeys = {modname .. ":bar_annealed"},
-- nodes = {
-- {
-- match = {name = modname .. ":bar_annealed"},
-- replace = "air"
-- },
-- {
-- y = -1,
-- match = {name = modname .. ":rod_annealed"},
-- replace = "air"
-- },
-- {
-- y = -2,
-- match = modname .. ":block_tempered"
-- }
-- },
-- items = {
-- modname .. ":adze_annealed"
-- }
-- })
-- nodecore.register_craft({
-- label = "recycle lode adze",
-- action = "pummel",
-- toolgroups = {choppy = 3},
-- indexkeys = {modname .. ":adze_hot"},
-- nodes = {
-- {
-- match = modname .. ":adze_hot",
-- replace = "air"
-- }
-- },
-- items = {
-- {name = modname .. ":bar_hot"},
-- {name = modname .. ":rod_hot"}
-- }
-- })
