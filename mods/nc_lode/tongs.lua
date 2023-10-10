-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore
    = ItemStack, math, minetest, nodecore
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hotlode = nodecore.group_expand("group:lode_temper_hot", true)

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
				if not hotlode[itemstack:get_name()] then return end

				-- item must be adjacent to tongs in inventory
				if myslot > itemslot + 1 or myslot < itemslot - 1 then return end

				-- Apply tool wear/breakage.
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

nodecore.register_lode_anvil_recipe({x = 1, y = -1}, function(temper)
		return {
			label = "anvil making lode tongs",
			action = "pummel",
			toolgroups = {thumpy = 3},
			indexkeys = {modname .. ":adze_" .. temper},
			nodes = {
				{
					match = {name = modname .. ":adze_" .. temper},
					replace = "air"
				},
				{
					x = 1,
					match = {name = modname .. ":adze_" .. temper},
					replace = "air"
				}
			},
			items = {{
					x = 1,
					name = modname .. ":tongs_" .. temper
			}}
		}
	end)
nodecore.register_craft({
		label = "recycle lode tongs",
		action = "pummel",
		toolgroups = {choppy = 3},
		indexkeys = {modname .. ":tongs_hot"},
		nodes = {
			{
				match = modname .. ":tongs_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":bar_hot", count = 2},
			{name = modname .. ":rod_hot", count = 2}
		}
	})

local function coolto(pos, stack, tempername)
	local def = minetest.registered_items[stack:get_name()]
	if not def then return end
	local alt = def["lode_alt_" .. tempername]
	if not alt then return end
	nodecore.witness(pos, "metallurgize " .. alt)
	nodecore.playcookfx(pos, true, "hiss", 80, 0.2)
	stack:set_name(alt)
	return stack
end

nodecore.register_aism({
		label = "tong-carried lode cooling",
		itemnames = {"group:lode_temper_hot"},
		action = function(stack, data)
			-- Don't conflict with cooking ABMs already operating on stack nodes
			if data.node then return end

			if nodecore.quenched(data.pos) then
				return coolto(data.pos, stack, "tempered")
			end

			local meta = stack:get_meta()
			local time = (meta:get_float("~annealtime") or 0) + 1
			if time >= 60 then
				return coolto(data.pos, stack, "annealed")
			end
			nodecore.playcookfx(data.pos, {smoke = true}, "", 2, 1)
			meta:set_float("~annealtime", time)
			return stack
		end
	})
