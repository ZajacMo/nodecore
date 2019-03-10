-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_floor, math_random
    = math.floor, math.random
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
		destroy_on_death = true
	})

local function shuffle(arr)
	for i = 1, #arr do
		local j = math_random(1, #arr)
		arr[i], arr[j] = arr[j], arr[i]
	end
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

	local slots = math_floor(nodecore.getphealth(player) / 20 * (size - 2)) + 2

	if #reg > slots then
		shuffle(reg)
		local pos = player:getpos()
		pos.y = pos.y + 1.65
		while #reg > slots do
			local i = reg[#reg]
			reg[#reg] = nil
			nodecore.item_eject(pos, inv:get_stack("main", i), 5)
			inv:set_stack("main", i, injured)
		end
		return
	end

	local fill = size - slots
	if #inj > fill then
		shuffle(inj)
		local pos = player:getpos()
		while #inj > fill do
			local i = inj[#inj]
			inj[#inj] = nil
			inv:set_stack("main", i, "")
		end
	end
end

minetest.register_globalstep(function()
		for _, p in pairs(minetest.get_connected_players()) do
			if p:get_hp() > 0 then checkinv(p) end
		end
	end)
