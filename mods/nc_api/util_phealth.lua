-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, type
    = math, minetest, nodecore, type
local math_ceil
    = math.ceil
-- LUALOCALS > ---------------------------------------------------------

local function getphealth(player)
	return player:get_hp() + player:get_meta():get_float("dhp")
end
nodecore.getphealth = getphealth

local function setphealth(player, hp, reason, minwhole)
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
nodecore.setphealth = setphealth

local function addphealth(player, hp, reason)
	return setphealth(player,
		getphealth(player) + hp,
		reason,
		hp >= 0 and player:get_hp())
end
nodecore.addphealth = addphealth

function nodecore.node_punch_hurt(pos, node, puncher, ...)
	if puncher and puncher:is_player() then
		addphealth(puncher, -1, {
				nc_type = "node_punch_hurt",
				node = node
			})
	end
	return minetest.node_punch(pos, node, puncher, ...)
end
