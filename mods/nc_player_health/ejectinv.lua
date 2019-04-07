-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, math_random, table_remove
    = math.floor, math.random, table.remove
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local injured = modname .. ":injured"
minetest.register_craftitem(injured, {
		description = "Injury",
		stack_max = 1,
		inventory_image = modname .. "_injured.png",
		wield_image = "nc_player_hand.png",
		wield_scale = {x = 1, y = 1, z = 2.5},
		on_drop = function(stack) return stack end,
		on_place = function(stack) return stack end,
		virtual_item = true
	})

local function pickend(q)
	for i = q, 1, -1 do
		if math_random() < 0.5 then return i end
	end
	return pickend(q)
end

local function checkinv(player)
	local inv = player:get_inventory()
	local size = inv:get_size("main")

	local inj = {}
	local reg = {}
	for i = 1, size do
		if inv:get_stack("main", i):get_name() == injured then
			inj[#inj + 1] = i
		else
			reg[#reg + 1] = i
		end
	end

	local slots = math_floor(nodecore.getphealth(player) / 20 * (size - 2) + 0.5) + 2

	if #reg > slots then
		local pos = player:get_pos()
		while #reg > slots do
			local n = pickend(#reg)
			local i = reg[n]
			table_remove(reg, n)
			local stack = inv:get_stack("main", i)
			if not (stack:get_definition() or {}).virtual_item then
				nodecore.item_eject(pos, stack, 5)
			end
			inv:set_stack("main", i, injured)
		end
		return
	end

	local fill = size - slots
	if #inj > fill then
		local pos = player:get_pos()
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

minetest.register_globalstep(function()
		for _, p in pairs(minetest.get_connected_players()) do
			if p:get_hp() > 0 then checkinv(p) end
		end
	end)
