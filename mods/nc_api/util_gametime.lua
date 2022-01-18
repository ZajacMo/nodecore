-- LUALOCALS < ---------------------------------------------------------
local error, math, minetest, nodecore, pairs, type
    = error, math, minetest, nodecore, pairs, type
local math_abs
    = math.abs
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()
local metakey = "gametime_adjust"
local raw = modstore:get_string(metakey)
local adjusts = raw and raw ~= "" and minetest.deserialize(raw, true) or {}

local dirty

-- name: key to identify adjustment
-- value: value to add to time
-- reset: if true, reset adjustment to this value offset, otherwise add
function nodecore.gametime_adjust(name, value, reset)
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

	if nodecore.gametime then
		nodecore.gametime = nodecore.gametime + value
	end

	adjusts[name] = value
	dirty = true

	return value
end

nodecore.register_globalstep("gametime", function(dtime)
		local mtt = minetest.get_gametime()
		local nct = nodecore.gametime
		for _, v in pairs(adjusts) do mtt = mtt + v end
		if not nct then
			nodecore.log("info", "nodecore.gametime: init to " .. mtt)
			nct = mtt
		end
		nct = nct + dtime
		if math_abs(nct - mtt) >= 2 then
			nodecore.log("warning", "nodecore.gametime: excess drift; nct="
				.. nct .. ", mtt=" .. mtt)
			nct = mtt
		end
		nodecore.gametime = nct
		if dirty then
			modstore:set_string(metakey, minetest.serialize(adjusts))
			dirty = nil
		end
	end)
