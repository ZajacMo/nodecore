-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, string
    = math, minetest, nodecore, string
local math_floor, string_format
    = math.floor, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local discharge_rate = 20
local max_charge = discharge_rate * 3600
local levels = 8
local level_exp = 1.5

local max_exp = max_charge ^ level_exp + 0.001

local fluid_water = nodecore.group_expand("group:water", true)
local fluid_flux = nodecore.group_expand("group:lux_fluid", true)
local function influid(pos)
	local n = minetest.get_node(pos).name
	if fluid_water[n] then return fluid_water end
	if fluid_flux[n] then return fluid_flux end
	pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	n = minetest.get_node(pos).name
	if fluid_water[n] then return fluid_water end
	if fluid_flux[n] then return fluid_flux end
end

local function floateq(a, b)
	if not (a and b) then return true end
	if a == 0 and b == 0 then return a == b end
	local ratio = a / b
	return ratio > 0.999 and ratio < 1.001
end
local function floatrpt(a, b)
	if floateq(a, b) then return string_format("%0.2f", a) end
	return string_format("%0.2f -> %0.2f", a, b)
end

local function getlevel(name)
	return minetest.get_item_group(name, modname) - 1
end

local function chargecalc(pos, oldname, meta)
	local fluid = influid(pos)
	local rate = (nodecore.lux_soak_rate(pos) or 0)
	- discharge_rate * ((fluid == fluid_water) and 2 or 1)
	if rate < 0 and fluid == fluid_flux then rate = 0 end

	local oldrate = meta:get_float("rate")
	local oldqty = meta:get_float("qty")
	local oldtime = meta:get_float("time")

	local now = nodecore.gametime
	local qty = (oldtime == 0)
	and ((getlevel(oldname) / levels * max_exp) ^ (1 / level_exp))
	or (oldqty + oldrate * (now - oldtime))
	if qty <= 0 then
		qty = 0
		if rate < 0 then rate = 0 end
	end
	if qty >= max_charge then
		qty = max_charge
		if rate > 0 then rate = 0 end
	end
	local level = math_floor((qty ^ level_exp) / max_exp * levels)
	local name = modname .. ":lamp" .. level

	if name == oldname and floateq(rate, oldrate) then return end

	nodecore.log("action", string_format("lantern level %s rate %s charge %s at %s",
			floatrpt(getlevel(oldname), level),
			floatrpt(oldrate, rate), floatrpt(oldqty, qty),
			minetest.pos_to_string(pos, 0)))

	meta:set_float("rate", rate)
	meta:set_float("qty", qty)
	meta:set_float("time", now)
	return name
end

nodecore.register_aism({
		label = "lantern charge",
		interval = 2,
		arealoaded = 14,
		itemnames = "group:" .. modname,
		action = function(stack, data)
			local pos = data.pos or data.player and data.player:get_pos()
			local name = chargecalc(pos, stack:get_name(), stack:get_meta())
			if name then
				stack:set_name(name)
				return stack
			end
		end
	})
nodecore.register_abm({
		label = "lantern charge",
		interval = 2,
		arealoaded = 14,
		nodenames = {"group:" .. modname},
		action = function(pos, node)
			local name = chargecalc(pos, node.name, minetest.get_meta(pos))
			if name then
				node.name = name
				return minetest.swap_node(pos, node)
			end
		end
	})
