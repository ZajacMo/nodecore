-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_exp, math_log
    = math.exp, math.log
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hand = minetest.registered_items[""]
local irradiated = modname .. ":irradiated"
minetest.register_craftitem(irradiated, {
		description = "Burn",
		stack_max = 1,
		inventory_image = "[combine:1x1",
		hotbar_type = "burn",
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

local function rademit(pos, emit)
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
				local pn = minetest.get_node(pt.under)
				local def = minetest.registered_items[pn.name] or {groups = {}}
				if def.groups.water then
					dsqr = dsqr * 8
				elseif pn.name ~= "air" and not def.groups.lux_emit then
					dsqr = dsqr * 2
				end
				if dsqr > (32 * 32) then return end
			end
		end
		luxaccum[pname] = (luxaccum[pname] or 0) + (math_log(emit) + 1) / dsqr
	end
end

nodecore.register_limited_abm({
		label = "Lux Irradiate",
		interval = 1,
		chance = 2,
		nodenames = {"group:lux_emit"},
		action = function(pos, node)
			local def = minetest.registered_items[node.name]
			local emit = def and def.groups and def.groups.lux_emit or 1
			if emit then return rademit(pos, emit) end
		end
	})

nodecore.register_aism({
		label = "Lux Stack Irradiate",
		interval = 1,
		chance = 2,
		itemnames = {"group:lux_emit"},
		action = function(stack, data)
			local def = minetest.registered_items[stack:get_name()]
			local emit = def and def.groups and def.groups.lux_emit
			or def and def.groups and def.groups.lux_tool
			and def.groups.lux_tool * 0.1
			if emit then return rademit(data.pos, emit) end
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

		local prop = math_exp(-accum / 10000)
		rad = rad * prop + (1 - prop)

		local redux = 0.1
		local pos = player:get_pos()
		local node = minetest.get_node(pos)
		local def = minetest.registered_items[node.name]
		if def and def.groups and def.groups.water then
			redux = redux + 50
		end
		pos.y = pos.y + 1
		node = minetest.get_node(pos)
		def = minetest.registered_items[node.name]
		if def and def.groups and def.groups.water then
			redux = redux + 500
		end
		prop = math_exp(-redux / 10000)
		rad = rad * prop

		meta:set_float("rad", rad)
	end
end
luxradpump()
