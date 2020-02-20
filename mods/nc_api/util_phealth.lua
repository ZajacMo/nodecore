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
	local hpmax = player:get_properties().hp_max
	if hp > hpmax then hp = hpmax end
	if hp < 0 then hp = 0 end
	local whole = math_ceil(hp)
	if whole == 0 then whole = 1 end
	local dhp = hp - whole
	player:get_meta():set_float("dhp", dhp)
	local old = player:get_hp()
	player:set_hp(whole)
	return old ~= whole
end
nodecore.setphealth = setphealth

local function addphealth(player, hp)
	local old = getphealth(player)
	if hp < 0 and old <= 1 then player:set_hp(2) end
	return setphealth(player, old + hp)
end
nodecore.addphealth = addphealth

function nodecore.node_punch_hurt(pos, node, puncher, ...)
	if puncher and puncher:is_player() then addphealth(puncher, -1) end
	return minetest.node_punch(pos, node, puncher, ...)
end
