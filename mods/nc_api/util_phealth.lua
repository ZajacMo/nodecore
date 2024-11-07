-- LUALOCALS < ---------------------------------------------------------
local math, nc, type
    = math, nc, type
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local function getphealth(player)
	if not (player and player.is_player and player:is_player()) then return 0 end
	return player:get_hp() + player:get_meta():get_float("dhp")
end
nc.getphealth = getphealth

local function setphealth(player, hp, reason, minwhole)
	if not (player and player.is_player and player:is_player()) then return end
	local hpmax = player:get_properties().hp_max
	if hp > hpmax then hp = hpmax end
	if hp < 0 then hp = 0 end
	local whole = math_ceil(hp)
	if whole == 0 then whole = 1 end
	if minwhole and whole < minwhole then whole = minwhole end
	local dhp = hp - whole
	player:get_meta():set_float("dhp", dhp)
	local old = player:get_hp()
	if type(reason) ~= "table" then reason = {nc_type = reason} end
	reason = reason or {}
	reason.from = "mod"
	reason.type = "set_hp"
	player:set_hp(whole, reason)
	return old ~= whole
end
nc.setphealth = setphealth

local function addphealth(player, hp, reason)
	return setphealth(player,
		getphealth(player) + hp,
		reason,
		hp >= 0 and player:get_hp())
end
nc.addphealth = addphealth
