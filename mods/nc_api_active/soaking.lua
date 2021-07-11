-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, pairs, type
    = error, math, minetest, nodecore, pairs, type
local math_floor, math_sqrt
    = math.floor, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local metacache = {}

local function metaget(meta, def, nodekey)
	local cached = nodekey and metacache[nodekey]
	local qty, time
	if cached then
		qty = cached.qty
		time = cached.time
	else
		qty = meta:get_float(def.fieldname .. "qty") or 0
		time = meta:get_float(def.fieldname .. "time")
	end
	return qty, time
end

local function metaset(meta, def, nodekey, qty, time)
	local cached = nodekey and metacache[nodekey]
	if not (cached and cached.qty == qty) then
		if qty then
			meta:set_float(def.fieldname .. "qty", qty)
		else
			meta:set_string(def.fieldname .. "qty", "")
		end
	end
	if not (cached and cached.time == time) then
		if time then
			meta:set_float(def.fieldname .. "time", time)
		else
			meta:set_string(def.fieldname .. "time", "")
		end
	end
	if nodekey then metacache[nodekey] = {qty = qty, time = time} end
end

local function soaking_core(def, reg, getmeta, getnodekey)
	if not def.fieldname then error("soaking def missing fieldname") end

	def.interval = def.interval or 1
	def.chance = def.chance or 1
	def.soakinterval = def.soakinterval or (def.interval * def.chance)

	if not def.soakrate then error("soaking missing soakrate callback") end
	if not def.soakcheck then error("soaking missing soakcheck callback") end

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

		local nodekey = getnodekey(...)
		local meta = getmeta(...)
		local total, start = metaget(meta, def, nodekey)
		start = start and start ~= 0 and start or now

		local rate = 0
		local delta = 0
		if start <= now then
			rate = def.soakrate(...)
			if rate == false then
				metaset(meta, def, nodekey)
				return ...
			end
			rate = rate or 0
			local ticks = 1 + math_floor((now - start) / def.soakinterval)
			delta = def.soakrand(rate, ticks)
			total = total + delta * rateadj
			start = start + ticks * def.soakinterval
		end

		local function helper(set, ...)
			if set == false then
				metaset(meta, def, nodekey)
				return ...
			end
			metaset(meta, def, nodekey,
				set and type(set) == "number" and set or total,
				start)
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

local soaking_abm_by_fieldname = {}
function nodecore.register_soaking_abm(def)
	soaking_abm_by_fieldname[def.fieldname] = def
	return soaking_core(def,
		minetest.register_abm,
		function(pos) return minetest.get_meta(pos) end,
		minetest.hash_node_position
	)
end
function nodecore.register_soaking_aism(def)
	return soaking_core(def,
		nodecore.register_aism,
		function(stack) return stack:get_meta() end,
		function() end
	)
end

local pending
function nodecore.soaking_abm_push(pos, fieldname, qty)
	local abm = soaking_abm_by_fieldname[fieldname]
	if not abm then return end

	local node = minetest.get_node(pos)

	local found
	for _, v in pairs(abm.nodenames or {}) do
		if node.name == v then
			found = true
		elseif v:sub(1, 6) == "group:" then
			found = found or minetest.get_item_group(node.name, v:sub(7)) ~= 0
		end
	end
	if not found then return end

	local meta = minetest.get_meta(pos)
	local qf = fieldname .. "qty"
	meta:set_float(qf, (meta:get_float(qf) or 0) + qty)
	local tf = fieldname .. "time"
	if (meta:get_float(tf) or 0) == 0 then meta:set_float(tf, nodecore.gametime) end

	local func = abm.action
	if pending then
		pending[#pending + 1] = function() return func(pos, node) end
	else
		pending = {}
		func(pos, node)
		while #pending > 0 do
			local batch = pending
			pending = {}
			for _, f in pairs(batch) do f() end
		end
		pending = nil
	end
end
