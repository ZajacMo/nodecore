-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_exp
    = math.exp
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hand = minetest.registered_items[""]
local irradiated = modname .. ":irradiated"
minetest.register_craftitem(irradiated, {
		description = "Burn",
		stack_max = 1,
		inventory_image = modname .. "_base.png^[mask:"
		.. modname .. "_icon_mask.png",
		wield_image = hand.wield_image,
		wield_scale = hand.wield_scale,
		on_drop = function(stack) return stack end,
		on_place = function(stack) return stack end,
		virtual_item = true
	})

nodecore.register_healthfx({
		item = irradiated,
		getqty = function(player)
			return player:get_meta():get_float("rad")
		end
	})

local luxaccum = {}

local function rademit(pos)
	for _, player in pairs(minetest.get_connected_players()) do
		local pname = player:get_player_name()
		local pp = player:get_pos()
		pp.y = pp.y + 1
		local dx = pp.x - pos.x
		dx = dx * dx
		local dy = pp.y - pos.y
		dy = dy * dy
		local dz = pp.z - pos.z
		dz = dz * dz
		local dsqr = (dx + dy + dz)
		if dsqr > (32 * 32) then return end
		if dsqr < 1 then
			dsqr = 1
		else
			for pt in minetest.raycast(pos, pp, false, true) do
				local node = minetest.get_node(pt.under)
				local def = minetest.registered_items[node.name]
				if def and def.groups and def.groups.water then
					dsqr = dsqr * 4
				elseif node.name ~= "air" then
					dsqr = dsqr * 1.5
				end
				if dsqr > (32 * 32) then return end
			end
		end
		luxaccum[pname] = (luxaccum[pname] or 0) + 1 / dsqr
	end
end

nodecore.register_limited_abm({
		label = "Lux Irradiate",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_emit"},
		action = rademit
	})

nodecore.register_limited_abm({
		label = "Lux Stack Irradiate",
		interval = 1,
		chance = 2,
		limited_max = 100,
		limited_alert = 1000,
		nodenames = {"group:visinv"},
		action = function(pos)
			local stack = nodecore.stack_get(pos)
			if stack:is_empty() then return end
			local def = minetest.registered_items[stack:get_name()]
			if def and def.groups and def.groups.lux_emit then
				return rademit(pos)
			end
		end
	})

local function luxradpump()
	minetest.after(1, luxradpump)
	for _, player in pairs(minetest.get_connected_players()) do
		local meta = player:get_meta()
		local rad = meta:get_float("rad") or 0

		local pname = player:get_player_name()
		local accum = luxaccum[pname] or 0
		luxaccum[pname] = 0
		local inv = player:get_inventory()
		for i = 1, inv:get_size("main") do
			local stack = inv:get_stack("main", i)
			local def = minetest.registered_items[stack:get_name()]
			if def and def.groups then
				if def.groups.lux_emit then accum = accum + 1 end
				if def.groups.lux_tool then accum = accum + 0.1 end
			end
		end
		local prop = math_exp(-accum / 1000)
		rad = rad * prop + (1 - prop)

		local redux = 0.02
		local pos = player:get_pos()
		local node = minetest.get_node(pos)
		local def = minetest.registered_items[node.name]
		if def and def.groups and def.groups.water then
			redux = redux + 10
		end
		pos.y = pos.y + 1
		node = minetest.get_node(pos)
		def = minetest.registered_items[node.name]
		if def and def.groups and def.groups.water then
			redux = redux + 100
		end
		prop = math_exp(-redux / 1000)
		rad = rad * prop

		meta:set_float("rad", rad)
	end
end
luxradpump()
