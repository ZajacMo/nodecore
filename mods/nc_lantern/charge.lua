-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, tostring
    = math, minetest, nodecore, tostring
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local discharge_rate = 30
local charge_per_level = discharge_rate * 300
local max_charge = charge_per_level * 8 - 1

nodecore.register_aism({
		label = "lantern charge",
		interval = 2,
		arealoaded = 14,
		itemnames = "group:" .. modname,
		action = function(stack, data)
			local pos = data.pos or data.player and data.player:get_pos()
			local wet = minetest.get_item_group(minetest.get_node(pos).name,
			"water") > 0
			local rate = (nodecore.lux_soak_rate(pos) or 0)
			- discharge_rate * (wet and 3 or 1)

			local oldname = stack:get_name()
			local meta = stack:get_meta()
			local oldrate = meta:get_float("rate")
			local oldqty = meta:get_float("qty")
			local oldtime = meta:get_float("time")

			local now = nodecore.gametime
			local qty = (oldtime == 0)
			and (minetest.get_item_group(oldname, modname) * charge_per_level)
			or (oldqty + oldrate * (now - oldtime))
			if qty < 0 then qty = 0 end
			if qty > max_charge then qty = max_charge end
			print(tostring(wet) .. qty)
			local name = modname .. ":lamp" .. math_floor(qty / charge_per_level)

			if name == oldname and rate == oldrate then return end

			stack:set_name(name)
			meta:set_float("rate", rate)
			meta:set_float("qty", qty)
			meta:set_float("time", now)
			return stack
		end
	})
