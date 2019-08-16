-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local function getphealth(player)
	return player:get_hp() + player:get_meta():get_float("dhp")
end
nodecore.getphealth = getphealth

local function setphealth(player, hp)
	if hp > 20 then hp = 20 end
	if hp < 0 then hp = 0 end
	local whole = math_ceil(hp)
	if whole == 0 then whole = 1 end
	local dhp = hp - whole
	player:get_meta():set_float("dhp", dhp)
	return player:set_hp(whole)
end
nodecore.setphealth = setphealth

local function addphealth(player, hp)
	return setphealth(player, getphealth(player) + hp)
end
nodecore.addphealth = addphealth

function nodecore.node_punch_hurt(pos, node, puncher, ...)
	if puncher and puncher:is_player() then addphealth(puncher, -1) end
	return minetest.node_punch(pos, node, puncher, ...)
end
