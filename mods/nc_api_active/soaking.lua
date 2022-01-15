-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, pairs, string, type, vector
    = error, math, minetest, nodecore, pairs, string, type, vector
local math_floor, math_sqrt, string_format
    = math.floor, math.sqrt, string.format
-- LUALOCALS > ---------------------------------------------------------

local metacache = {}

nodecore.register_on_nodeupdate(function(pos)
		metacache[minetest.hash_node_position(pos)] = nil
	end)

local function metaget(meta, def, nodekey)
	local fn = def.fieldname
	local cached = nodekey and metacache[nodekey]
	local inner = cached and cached[fn]
	if inner then return inner end
	inner = {
		qty = meta:get_float(fn .. "qty"),
		time = meta:get_float(fn .. "time")
	}
	if inner.qty == 0 then inner.qty = nil end
	if inner.time == 0 then inner.time = nil end
	if nodekey then
		cached = cached or {}
		cached[fn] = inner
		metacache[nodekey] = cached
	end
	return inner
end

local function metaset_core(meta, field, value)
	if value then
		return meta:set_float(field, value)
	else
		return meta:set_string(field, "")
	end
end

local function metaset(meta, def, nodekey, qty, time)
	local cached = metaget(meta, def, nodekey)
	if qty == 0 then qty = nil end
	if cached.qty ~= qty then
		metaset_core(meta, def.fieldname .. "qty", qty)
		cached.qty = qty
	end
	if time == 0 then time = nil end
	if cached.time ~= time then
		metaset_core(meta, def.fieldname .. "time", time)
		cached.time = time
	end
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
		local nodekey = getnodekey(...)
		local meta = getmeta(...)
		if def.quickcheck and not def.quickcheck(...) then
			metaset(meta, def, nodekey)
			return ...
		end

		local now = nodecore.gametime

		local metadata = metaget(meta, def, nodekey)
		local total = metadata.qty or 0
		local start = metadata.time
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
	def.nodeidx = nodecore.group_expand(def.nodenames, true)
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
	if not abm.nodeidx[node.name] then return end

	local meta = minetest.get_meta(pos)
	local nodekey = minetest.hash_node_position(vector.round(pos))
	local data = metaget(meta, abm, nodekey)
	metaset(meta, abm, nodekey, (data.qty or 0) + qty, data.time or nodecore.gametime)

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

function nodecore.soaking_abm_tickle(pos, fieldname)
	local abm = soaking_abm_by_fieldname[fieldname]
	if not abm then return end

	local node = minetest.get_node(pos)
	if not abm.nodeidx[node.name] then return end

	local rate = abm.soakrate(pos, node)
	if not rate then return end

	local meta = minetest.get_meta(pos)
	local tickletime = meta:get_float(fieldname .. "tickle")
	if not (tickletime and tickletime > 0
		and tickletime < nodecore.gametime) then
		tickletime = nodecore.gametime
	end
	meta:set_float(fieldname .. "tickle", nodecore.gametime)
	local qty = ((nodecore.gametime - tickletime) ^ 0.5) * rate * 10
	nodecore.log("action", string_format("abm push %0.2f for %q at %s",
			qty, fieldname, minetest.pos_to_string(pos)))
	nodecore.soaking_abm_push(pos, fieldname, qty)
	return qty
end

do
	local zero = {x = 0, y = 0, z = 0}
	function nodecore.soaking_particles(pos, amount, time, width, nodename)
		nodename = nodename or minetest.get_node(pos).name
		local def = minetest.registered_items[nodename]
		if not def then return end
		nodecore.digparticles(def,
			{
				amount = amount,
				time = time,
				minpos = {
					x = pos.x - width,
					y = pos.y + 33/64,
					z = pos.z - width
				},
				maxpos = {
					x = pos.x + width,
					y = pos.y + 33/64,
					z = pos.z + width
				},
				minvel = zero,
				maxvel = zero,
				minexptime = 0.25,
				maxexptime = 1,
				minsize = 3 * width,
				maxsize = 9 * width,
			})
	end
end
