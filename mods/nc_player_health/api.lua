-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_floor, math_random, table_remove, table_sort
    = math.floor, math.random, table.remove, table.sort
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_healthfx,
nodecore.registered_healthfx
= nodecore.mkreg()

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

local function checkinv(player)
	local dmg = minetest.settings:get_bool("enable_damage")
	local inv = player:get_inventory()
	local size = inv:get_size("main")
	local max = size - 2

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
			local pos = player:get_pos()
			while #reg > need do
				local n = pickend(#reg)
				local i = reg[n]
				table_remove(reg, n)
				local stack = inv:get_stack("main", i)
				if not nodecore.item_is_virtual(stack) then
					nodecore.item_eject(pos, stack, 5)
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

minetest.register_globalstep(function()
		for _, p in pairs(minetest.get_connected_players()) do
			if p:get_hp() > 0 then checkinv(p) end
		end
	end)
