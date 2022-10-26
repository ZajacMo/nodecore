-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, math_random, table_remove, table_sort
    = math.floor, math.random, table.remove, table.sort
-- LUALOCALS > ---------------------------------------------------------

-- item = "name" [required]
-- - virtual item to use in hotbar for damage
-- getqty(player) [required]
-- - get the proportion (0.0-1.0) of the hotbar that should be damaged by this effect
-- setqty(player, qty, reason) [recommended]
-- - set the damaged proportion (0.0-1.0) of the hotbar

nodecore.register_healthfx,
nodecore.registered_healthfx
= nodecore.mkreg()

minetest.register_privilege("ncdqd", {
		description = "Invulnerable to all kinds of damage",
		give_to_singleplayer = false,
		give_to_admin = false
	})

function nodecore.player_can_take_damage(player)
	return not player:get_armor_groups().immortal
	and not minetest.get_player_privs(player).ncdqd
end

function nodecore.register_virtual_item(name, def)
	return minetest.register_craftitem(name, nodecore.underride(def, {
				on_use = function() end,
				on_drop = function(stack) return stack end,
				on_place = function(stack) return stack end,
				description = "",
				inventory_image = "[combine:1x1",
				wield_image = "[combine:1x1",
				virtual_item = true,
				wield_no_anim_mine = true,
				wield_no_anim_place = true,
				stack_max = 1,
				node_placement_prediction = "",
			}))
end

local function pickend(q)
	for i = q, 1, -1 do
		if math_random() < 0.5 then return i end
	end
	return pickend(q)
end

local function rounddist(n)
	n = n - math_floor(n)
	if n < 0.5 then return n end
	return 1 - n
end

nodecore.register_playerstep({
		label = "health virtual items",
		action = function(player)
			if player:get_hp() <= 0 then return end

			local dmg = nodecore.player_can_take_damage(player)
			local inv = player:get_inventory()
			local size = inv:get_size("main")
			local max = size - 1

			local items = {}
			for _, def in pairs(nodecore.registered_healthfx) do
				items[def.item] = {}
			end

			local reg = {}
			for i = 1, size do
				local name = inv:get_stack("main", i):get_name()
				local tbl = items[name]
				if tbl then
					tbl[#tbl + 1] = i
				else
					reg[#reg + 1] = i
				end
			end

			local slots = {}
			local total = 0
			for _, def in pairs(nodecore.registered_healthfx) do
				local q = dmg and (def.getqty(player) * (max + 1) - 1) or 0
				if q > max then q = max end
				if q < 0 then q = 0 end
				slots[#slots + 1] = {item = def.item, qty = size - q}
				total = total + 1
			end
			if total > max then
				for _, v in pairs(slots) do
					v.qty = v.qty * max / total
				end
				table_sort(slots, function(a, b) return rounddist(a.qty) < rounddist(b.qty) end)
				local resid = 0
				for _, v in pairs(slots) do
					resid = resid + v.qty - math_floor(v.qty)
					if resid > 0.5 then
						v.qty = v.qty + 1
						resid = resid - 1
					end
				end
			end

			local slotidx = {}
			for _, v in pairs(slots) do slotidx[v.item] = math_floor(v.qty) end

			for _, def in pairs(nodecore.registered_healthfx) do
				local need = slotidx[def.item]

				if #reg > need then
					while #reg > need do
						local n = pickend(#reg)
						local i = reg[n]
						table_remove(reg, n)
						local stack = inv:get_stack("main", i)
						if not nodecore.item_is_virtual(stack) then
							nodecore.item_lose(player, "main", i, 5)
						end
						inv:set_stack("main", i, def.item)
					end
					return
				end

				local inj = items[def.item]
				local fill = size - need
				if #inj > fill then
					for i = 1, #inj / 2 do
						inj[i], inj[#inj + 1 - i] = inj[#inj + 1 - i], inj[i]
					end
					while #inj > fill do
						local n = pickend(#inj)
						local i = inj[n]
						table_remove(inj, n)
						inv:set_stack("main", i, "")
					end
				end
			end
		end
	})
