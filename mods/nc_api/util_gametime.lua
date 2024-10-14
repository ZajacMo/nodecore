-- LUALOCALS < ---------------------------------------------------------
local core, error, math, nc, pairs, type
    = core, error, math, nc, pairs, type
local math_abs
    = math.abs
-- LUALOCALS > ---------------------------------------------------------

local modstore = core.get_mod_storage()
local metakey = "gametime_adjust"
local raw = modstore:get_string(metakey)
local adjusts = raw and raw ~= "" and core.deserialize(raw, true) or {}

local dirty

-- name: key to identify adjustment
-- value: value to add to time
-- reset: if true, reset adjustment to this value offset, otherwise add
function nc.gametime_adjust(name, value, reset)
	local old = adjusts[name] or 0
	if not value then return old end

	if type(value) ~= "number" then
		error("invalid gametime_adjust " .. type(value))
	end

	if not reset then value = value + old end
	if value == old then return end
	if value < old then
		error("time cannot be adjusted backwards")
	end

	if nc.gametime then
		nc.gametime = nc.gametime + value
	end

	adjusts[name] = value
	dirty = true

	return value
end

nc.register_globalstep(function(dtime)
		local mtt = core.get_gametime()
		local nct = nc.gametime
		for _, v in pairs(adjusts) do mtt = mtt + v end
		if not nct then
			nc.log("info", "nc.gametime: init to " .. mtt)
			nct = mtt
		end
		nct = nct + dtime
		if math_abs(nct - mtt) >= 2 then
			nc.log("warning", "nc.gametime: excess drift; nct="
				.. nct .. ", mtt=" .. mtt)
			nct = mtt
		end
		nc.gametime = nct
		if dirty then
			modstore:set_string(metakey, core.serialize(adjusts))
			dirty = nil
		end
	end)
