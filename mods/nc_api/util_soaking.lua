-- LUALOCALS < ---------------------------------------------------------
local nodecore, type
    = nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local function clr(meta, key, ...)
	local t = meta:to_table()
	t[key] = nil
	meta:from_table(t)
	return ...
end

local function soaking(meta, key, max, rate)
	if not rate then return clr(meta, key) end
	if type(rate) ~= "number" then rate = 1 end
	local t = (meta:get_float(key) or 0) + rate
	if t >= max then return clr(meta, key, true) end
	meta:set_float(key, t)
	return false, true
end
nodecore.soaking = soaking

function nodecore.cooking(meta, key, max, rate, pos, smoketime)
	local done, prog = soaking(meta, key, max, rate)
	nodecore.smoke(pos, prog and (smoketime or 1))
	return done
end
