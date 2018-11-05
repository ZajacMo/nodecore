-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local health_bar_definition =
{
	hud_elem_type = "statbar",
	position = { x=0.5, y=1 },
	text = "heart_bg.png",
	number = 20,
	direction = 0,
	size = { x=24, y=24 },
	offset = { x=(-10*24)-25, y=-(48+24+16)},
}

local breath_bar_definition =
{
	hud_elem_type = "statbar",
	position = { x=0.5, y=1 },
	text = "bubble_bg.png",
	number = 20,
	direction = 0,
	size = { x=24, y=24 },
	offset = {x=25,y=-(48+24+16)},
}

local reg_bubbles = {}

local function checkbubbles(player)
	local name = player:get_player_name()
	if player:get_breath() < 11 then
		reg_bubbles[name] = reg_bubbles[name] or player:hud_add(breath_bar_definition)
	elseif reg_bubbles[name] then
		player:hud_remove(reg_bubbles[name])
		reg_bubbles[name] = nil
	end
end

minetest.register_playerevent(checkbubbles)

minetest.register_on_joinplayer(function(player)
		minetest.after(0, function()
				player:hud_add(health_bar_definition)
				checkbubbles(player)
			end)
	end)
