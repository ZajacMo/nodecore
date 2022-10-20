-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local charge_per_level = 500
local discharge_rate = 30

nodecore.register_soaking_aism({
		label = "lantern charge",
		fieldname = "charge",
		interval = 10,
		arealoaded = 14,
		itemnames = "group:" .. modname,
		soakrate = function(_, aismdata)
			local pos = aismdata.pos or aismdata.player and aismdata.player:get_pos()
			local wet = minetest.get_item_group(minetest.get_node(pos), "moist") > 0
			return (nodecore.lux_soak_rate(pos) or 0)
			- discharge_rate * (wet and 3 or 1)
		end,
		soakcheck = function(data, stack)
			if data.total < 0 then data.total = 0 end
			if data.total >= charge_per_level * 8 then
				data.total = charge_per_level * 8 - 1
			end
			stack:set_name(modname .. ":lamp" .. math_floor(
					data.total / charge_per_level))
			return data.total, stack
		end
	})
