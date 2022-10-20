-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string
    = math, minetest, nodecore, pairs, string
local math_floor, string_format
    = math.floor, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local discharge_rate = 30
local charge_per_level = discharge_rate * 300
local max_charge = charge_per_level * 8 - 1

local waters = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.water and v.groups.water > 0 then
				waters[k] = true
			end
		end
	end)
local function iswater(pos) return waters[minetest.get_node(pos).name] end
local function iswet(pos)
	if iswater(pos) then return true end
	local p = {x = pos.x, y = pos.y + 1, z = pos.z}
	return iswater(p)
end

local function floateq(a, b)
	if not (a and b) then return true end
	if a == 0 and b == 0 then return a == b end
	local ratio = a / b
	return ratio > 0.999 and ratio < 1.001
end
local function floatrpt(a, b)
	if floateq(a, b) then return string_format("%0.2f", a) end
	return string.format("%0.2f -> %0.2f", a, b)
end

local function getlevel(name)
	return minetest.get_item_group(name, modname) - 1
end

nodecore.register_aism({
		label = "lantern charge",
		interval = 2,
		arealoaded = 14,
		itemnames = "group:" .. modname,
		action = function(stack, data)
			local pos = data.pos or data.player and data.player:get_pos()
			local rate = (nodecore.lux_soak_rate(pos) or 0)
			- discharge_rate * (iswet(pos) and 3 or 1)

			local oldname = stack:get_name()
			local meta = stack:get_meta()
			local oldrate = meta:get_float("rate")
			local oldqty = meta:get_float("qty")
			local oldtime = meta:get_float("time")

			local now = nodecore.gametime
			local qty = (oldtime == 0)
			and (getlevel(oldname) * charge_per_level)
			or (oldqty + oldrate * (now - oldtime))
			if qty <= 0 then
				qty = 0
				if rate < 0 then rate = 0 end
			end
			if qty >= max_charge then
				qty = max_charge
				if rate > 0 then rate = 0 end
			end
			local level = math_floor(qty / charge_per_level)
			local name = modname .. ":lamp" .. level

			if name == oldname and floateq(rate, oldrate) then return end

			nodecore.log("action", string_format("lantern level %s rate %s charge %s at %s",
					floatrpt(getlevel(oldname), level),
					floatrpt(oldrate, rate), floatrpt(oldqty, qty),
					minetest.pos_to_string(pos, 0)))

			stack:set_name(name)
			meta:set_float("rate", rate)
			meta:set_float("qty", qty)
			meta:set_float("time", now)
			return stack
		end
	})
