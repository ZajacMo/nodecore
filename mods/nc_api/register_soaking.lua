-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, type
    = error, math, minetest, nodecore, type
local math_floor, math_sqrt
    = math.floor, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local function soaking_core(def, reg, getmeta)
	def.qtyfield = def.qtyfield or "soakqty"
	def.timefield = def.timefield or "soaktime"

	def.soakinterval = def.soakinterval or ((def.interval or 1) * (def.chance or 1))

	if not def.soakrate then error("soaking abm missing soakrate callback") end
	if not def.soakcheck then error("soaking abm missing soakcheck callback") end

	def.soakvary = def.soakvary or 0.25
	if not def.soakrand then
		if def.soakvary then
			def.soakrand = function(rate, ticks)
				return rate * (1 + def.soakvary * nodecore.boxmuller()
					/ math_sqrt(ticks)) * ticks
			end
		else
			def.soakrand = function(rate, ticks) return rate * ticks end
		end
	end

	local rateadj = nodecore.rate_adjustment("speed", "soaking", def.label)
	def.action = function(...)
		local now = nodecore.gametime

		local meta = getmeta(...)
		local total = meta:get_float(def.qtyfield) or 0
		local start = meta:get_float(def.timefield)
		start = start and start ~= 0 and start or now

		local rate = 0
		local delta = 0
		if start <= now then
			rate = def.soakrate(...)
			if rate == false then
				meta:set_string(def.qtyfield, "")
				meta:set_string(def.timefield, "")
				return
			end
			rate = rate or 0
			local ticks = 1 + math_floor((now - start) / def.soakinterval)
			delta = def.soakrand(rate, ticks)
			total = total + delta * rateadj
			start = start + ticks * def.soakinterval
		end

		local function helper(set, ...)
			if set == false then
				meta:set_string(def.qtyfield, "")
				meta:set_string(def.timefield, "")
				return
			end
			meta:set_float(def.qtyfield, set and type(set) == "number" and set or total)
			meta:set_float(def.timefield, start)
			return ...
		end
		return helper(def.soakcheck({
					rate = rate,
					delta = delta,
					total = total
				}, ...))
	end

	return reg(def)
end

function nodecore.register_soaking_abm(def)
	return soaking_core(def,
		nodecore.register_limited_abm,
		function(pos) return minetest.get_meta(pos) end
	)
end
function nodecore.register_soaking_aism(def)
	return soaking_core(def,
		nodecore.register_aism,
		function(stack) return stack:get_meta() end
	)
end
