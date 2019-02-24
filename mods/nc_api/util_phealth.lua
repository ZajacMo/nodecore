-- LUALOCALS < ---------------------------------------------------------
local math, nodecore, tonumber, tostring
    = math, nodecore, tonumber, tostring
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local function getphealth(player)
	return player:get_hp()
	+ tonumber(player:get_attribute("dhp") or "0")
end
nodecore.getphealth = getphealth

local function setphealth(player, hp)
	if hp > 20 then hp = 20 end
	if hp < 0 then hp = 0 end
	local whole = math_ceil(hp)
	local dhp = hp - whole
	player:set_attribute("dhp", tostring(dhp))
	return player:set_hp(whole)
end
nodecore.setphealth = setphealth

function nodecore.addphealth(player, hp)
	return setphealth(player, getphealth(player) + hp)
end
