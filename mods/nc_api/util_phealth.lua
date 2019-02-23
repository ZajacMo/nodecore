-- LUALOCALS < ---------------------------------------------------------
local math, nodecore, tonumber, tostring
    = math, nodecore, tonumber, tostring
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

function nodecore.addphealth(player, hp)
	local total = player:get_hp() + hp
	+ tonumber(player:get_attribute("dhp") or "0")
	if total > 20 then total = 20 end
	if total < 0 then total = 0 end
	local whole = math_ceil(total)
	local dhp = total - whole
	player:set_attribute("dhp", tostring(dhp))
	return player:set_hp(whole)
end
